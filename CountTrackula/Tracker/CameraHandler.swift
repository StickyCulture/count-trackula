import AVFoundation
import CoreImage

@Observable class CameraHandler: NSObject {
    public var tracker = BodyTracker()
    public var sampleBuffer: CMSampleBuffer?
    public var availableCameras = [AVCaptureDevice]()
    public var currentCamera: AVCaptureDevice?

    private var permissionGranted = true
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "tv.sticky.CountTrackula.sessionQueue")
    private let trackingQueue = DispatchQueue(label: "tv.sticky.CountTrackula.trackingQueue", qos: .userInitiated)
    private let context = CIContext()
    
    override init() {
        super.init()
        self.checkPermission()
        sessionQueue.async { [unowned self] in
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            self.permissionGranted = true
            
        case .notDetermined: // The user has not yet been asked for camera access.
            self.requestPermission()
            
            // Combine the two other cases into the default case
        default:
            self.permissionGranted = false
        }
    }
    
    func requestPermission() {
        // Strong reference not a problem here but might become one in the future.
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    
    func setupCaptureSession() {
        guard permissionGranted else {
            print("Camera permission not granted.")
            return
        }
        
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInUltraWideCamera,
                .builtInWideAngleCamera,
                .builtInTelephotoCamera,
            ],
            mediaType: .video,
            position: .back
        )
        self.availableCameras = discoverySession.devices
        
        // Check for saved value in settings
        let cameraDeviceIndex = Settings.cameraDeviceIndex.value
        if cameraDeviceIndex < availableCameras.count {
            self.switchCamera(to: availableCameras[cameraDeviceIndex])
        } else if let firstCamera = availableCameras.first {
            print("Saved camera index is out of range. Switching to the first available camera.")
            self.switchCamera(to: firstCamera)
        } else {
            print("Could not find a suitable camera device.")
        }
    }
    
    func switchCamera(to newCamera: AVCaptureDevice) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            self.captureSession.stopRunning()
            
            // remove any current inputs and outputs
            if let currentInput = self.captureSession.inputs.first {
                self.captureSession.removeInput(currentInput)
            }
            if let currentOutput = self.captureSession.outputs.first {
                self.captureSession.removeOutput(currentOutput)
            }
            
            self.currentCamera = newCamera
            
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: newCamera) else {
                print("Could not create video device input.")
                return
            }
            
            guard captureSession.canAddInput(videoDeviceInput) else {
                print("captureSession can't add input")
                return
            }
            captureSession.addInput(videoDeviceInput)
            captureSession.sessionPreset = .vga640x480
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
            captureSession.addOutput(videoOutput)
            
            self.captureSession.startRunning()
            
            setCameraZoom(Settings.cameraZoomFactor.value)
        }
    }

    func setCameraZoom(_ factor: Double) {
        guard let device = currentCamera else { return }
        do {
            try device.lockForConfiguration()
            device.ramp(toVideoZoomFactor: CGFloat(factor), withRate: 3.0)
            device.unlockForConfiguration()
        } catch {
            print("Failed to set zoom: \(error)")
        }
    }
}


extension CameraHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // All UI updates should be/ must be performed on the main queue.
        DispatchQueue.main.async { [unowned self] in
            self.sampleBuffer = sampleBuffer
        }
        trackingQueue.async {
            try? self.tracker.handleBuffer(sampleBuffer: sampleBuffer)
        }
    }
    
    public var imageFrame: CGImage? {
        guard let sampleBuffer = self.sampleBuffer, let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        return cgImage
    }
}

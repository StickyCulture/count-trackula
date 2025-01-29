import SwiftUI

struct CameraSettingsView: View {
#if !targetEnvironment(simulator)
    @Environment(CameraHandler.self) private var camera: CameraHandler
#endif

    @AppStorage(Settings.cameraDeviceIndex.key) private var cameraDeviceIndex = Settings.cameraDeviceIndex.value
    @AppStorage(Settings.cameraZoomFactor.key) private var cameraZoomFactor = Settings.cameraZoomFactor.value
    
    var body: some View {
        Section("Camera") {
#if targetEnvironment(simulator)
            Text("Cannot show camera settings in Simulator Preview")
#else
            VStack {
                Picker("Device", selection: $cameraDeviceIndex) {
                    ForEach(camera.availableCameras.indices, id: \.self) { index in
                        Text(camera.availableCameras[index].localizedName)
                            .tag(index)
                    }
                }
                .pickerStyle(.automatic)
                .onChange(of: cameraDeviceIndex) {
                    camera.switchCamera(to: camera.availableCameras[cameraDeviceIndex])
                }
            }
            VStack {
                HStack {
                    Text("Zoom Factor")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    SettingsValueBlock(cameraZoomFactor.formatted(.number))
                }
                Slider(
                    value: $cameraZoomFactor,
                    in: 1.0...3.0, // TODO: limit upper value based on device capability
                    step: 0.1
                )
                .onChange(of: cameraZoomFactor) {
                    camera.setCameraZoom(cameraZoomFactor)
                }
            }
#endif
        }
    }
}

#Preview {
    Form {
        CameraSettingsView()
    }
}

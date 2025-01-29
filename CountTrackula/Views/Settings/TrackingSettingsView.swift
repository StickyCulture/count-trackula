import SwiftUI

struct TrackingSettingsView: View {
    @Environment(CameraHandler.self) var camera: CameraHandler?
    
    @AppStorage(Settings.maxTrackingTimeout.key) private var maxTrackingTimeout: Int = Settings.maxTrackingTimeout.value
    @AppStorage(Settings.redetectionInterval.key) private var redetectionInterval: Int = Settings.redetectionInterval.value
    @AppStorage(Settings.trackingConfidence.key) private var trackingConfidence: Double = Settings.trackingConfidence.value
    
    var body: some View {
        Section("Tracking") {
            VStack {
                Stepper(
                    value: $maxTrackingTimeout,
                    in: 0...1000,
                    step: 10
                ) {
                    HStack {
                        Text("Exit Timeout")
                        Spacer()
                        SettingsValueBlock(maxTrackingTimeout.description)
                    }
                }
                SettingsDescription("The maximum number of frames to wait before considering a lost body to have exited.")
            }
            .onChange(of: maxTrackingTimeout) {
                if let camera = camera {
                    camera.tracker.maxTrackingTimeout = maxTrackingTimeout
                }
            }
            VStack {
                Stepper(
                    value: $redetectionInterval,
                    in: 0...1000,
                    step: 10
                ) {
                    HStack {
                        Text("Re-detection Interval")
                        Spacer()
                        SettingsValueBlock(redetectionInterval.description)
                    }
                }
                SettingsDescription("The maximum number of frames to wait before attempting a re-detection of bodies.")
            }
            .onChange(of: redetectionInterval) {
                if let camera = camera {
                    camera.tracker.redetectionInterval = redetectionInterval
                }
            }
            VStack {
                HStack {
                    Text("Minimum Confidence")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    SettingsValueBlock(trackingConfidence.formatted(.percent))
                }
                Slider(
                    value: $trackingConfidence,
                    in: 0.0...1.0,
                    step: 0.05
                )
                SettingsDescription("The minimum confidence level required to be considered an accurate detection.")
                SettingsDescription("A low confidence may produce false positives. A high confidence may struggle to find anything.")
            }
            .onChange(of: trackingConfidence) {
                if let camera = camera {
                    camera.tracker.trackingConfidence = trackingConfidence
                }
            }
        }
    }
}

#Preview {
    Form {
        TrackingSettingsView()
    }
}

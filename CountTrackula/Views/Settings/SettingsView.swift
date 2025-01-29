import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            CameraSettingsView()
            TrackingSettingsView()
            CountingSettingsView()
            BoundarySettingsView()
            AnalyticsSettingsView()
        }
        .foregroundColor(.text)
        .tint(.blood)
    }
}

#Preview {
    SettingsView()
}

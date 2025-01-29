import SwiftUI

/// Count Trackula expects an `Analytics` struct that conforms to `AnalyticsProtocol`.
///
/// We do not track the `Analytics` struct in version control. The idea is to generalize the behavior so that it is easy to hook up to your own solution.
protocol AnalyticsProtocol {
    static var shared: Self { get }
    
    var application: String { get set }
    var instance: String { get set }
    var isDisabled: Bool { get set }
    var isDevelopment: Bool { get set }
    
    func trackEntrance(for id: Int)
    func trackExit(for id: Int)
    func trackError(for id: Int, description: String)
    func trackSystemEvent(description: String, value: Any?)
}

struct AnalyticsSettingsView: View {
    @AppStorage(Settings.analyticsIsDevelopment.key) private var isDevelopment: Bool = Settings.analyticsIsDevelopment.value
    @AppStorage(Settings.analyticsIsDisabled.key) private var isDisabled: Bool = Settings.analyticsIsDisabled.value
    @AppStorage(Settings.analyticsApplication.key) private var application: String = Settings.analyticsApplication.value
    @AppStorage(Settings.analyticsInstance.key) private var instance: String = Settings.analyticsInstance.value
    
    var body: some View {
        Section("Analytics") {
            VStack {
                HStack {
                    Text("Collection Name")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                TextField("", text: $application)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(10)
                    .background(Color.black.opacity(0.3))
                    .foregroundColor(Color.primary)
                    .borderRadius(5, corners: .allCorners)
                SettingsDescription("The name of the Firebase collection where events are recorded.")
                if isDevelopment {
                    SettingsDescription("Currently recording to '\(application)-dev' because Development Mode is enabled." )
                }
            }
            .onChange(of: application) {
                Analytics.shared.application = application
            }
            
            VStack {
                HStack {
                    Text("Device Identity")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                TextField("Device Identity", text: $instance)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(10)
                    .background(Color.black.opacity(0.3))
                    .foregroundColor(Color.primary)
                    .borderRadius(5, corners: .allCorners)
                SettingsDescription("Events are tagged with this name. Useful for identifying source.")
            }
            .onChange(of: instance) {
                Analytics.shared.instance = instance
            }
            
            VStack {
                Toggle(isOn: $isDevelopment) {
                    HStack {
                        Text("Development Mode")
                    }
                }
                if !isDisabled {
                    SettingsDescription("Currently recording events to \(application)\(isDevelopment ? "-dev" : "")" )
                } else {
                    SettingsDescription("Event recording is currently disabled." )
                }
            }
            .onChange(of: isDevelopment) {
                Analytics.shared.isDevelopment = isDevelopment
            }
            
            VStack {
                Toggle(isOn: $isDisabled) {
                    HStack {
                        Text("Disable Recording")
                    }
                }
                SettingsDescription("Currently\(isDisabled ? " NOT " : " ")recording events. Toggle this field to change." )
            }
            .onChange(of: isDisabled) {
                Analytics.shared.isDisabled = isDisabled
            }
        }
    }
}

#Preview {
    Form {
        AnalyticsSettingsView()
    }
}

import UIKit

class ThermalMonitor {
    init() {
        print("🌡️ Initializing thermal monitor")
        printThermalState(ProcessInfo.processInfo.thermalState)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(thermalStateDidChange),
            name: ProcessInfo.thermalStateDidChangeNotification,
            object: nil
        )
    }
    
    @objc func thermalStateDidChange(notification: Notification) {
        printThermalState(ProcessInfo.processInfo.thermalState)
    }
    
    func printThermalState(_ state: ProcessInfo.ThermalState) {
        var thermalStateString: String
        switch state {
        case .nominal:
            thermalStateString = "nominal"
            print("🟩 Thermal state is \(thermalStateString)")
        case .fair:
            thermalStateString = "fair"
            print("🟨 Thermal state is \(thermalStateString)")
        case .serious:
            thermalStateString = "serious"
            print("🟧 Thermal state is \(thermalStateString)")
        case .critical:
            thermalStateString = "critical"
            print("🟥 Thermal state is \(thermalStateString)")
        @unknown default:
            thermalStateString = "unknown"
            print("Unknown thermal state")
        }
        if (Analytics.shared.isDevelopment) {
            Analytics.shared.trackSystemEvent(description: "Thermal State", value: thermalStateString)
        }
    }
}

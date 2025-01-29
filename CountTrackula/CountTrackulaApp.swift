import SwiftUI
import SwiftData

@main
struct CountTrackulaApp: App {
    let thermalMonitor = ThermalMonitor()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

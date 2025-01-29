import SwiftUI

struct CountingSettingsView: View {
    @AppStorage(Settings.minimumTravel.key) private var minimumTravel = Settings.minimumTravel.value
    
    var body: some View {
        Section("Counting") {
            VStack {
                HStack {
                    Text("Minimum Travel")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    SettingsValueBlock(minimumTravel.formatted(.number))
                }
                Slider(
                    value: $minimumTravel,
                    in: 0.0...1.0,
                    step: 0.01
                )
                SettingsDescription("The minimum distance along the axis of interest that must be traveled in order to count.")
            }
        }
    }
}

#Preview {
    Form {
        CountingSettingsView()
    }
}

import SwiftUI

struct BoundarySettingsView: View {
    @AppStorage(Settings.isOutsideOnTop.key) private var isOutsideOnTop = Settings.isOutsideOnTop.value
    @AppStorage(Settings.isVerticalBoundary.key) private var isVerticalBoundary = Settings.isVerticalBoundary.value
    @AppStorage(Settings.boundaryPosition.key) private var boundaryPosition = Settings.boundaryPosition.value

    var body: some View {
        Section("Boundary") {
            Text("The following items can be edited directly in the main window.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(0.8)
                .padding(.vertical, 10)
            VStack {
                HStack {
                    Text("Line Position")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    SettingsValueBlock(boundaryPosition.formatted(.number))
                }
                Slider(
                    value: $boundaryPosition,
                    in: 0.0...1.0,
                    step: 0.01
                )
                SettingsDescription("The normalized position of the line that separates this world from the next.")
                SettingsDescription("Currently from \(isVerticalBoundary ? "left to right." : "top to bottom.")")
            }
            VStack {
                Toggle(isOn: $isOutsideOnTop) {
                    HStack {
                        Text("Flip Inside/Outside")
                    }
                }
                SettingsDescription("Currently signifies that the 'outside' is " + (isOutsideOnTop ? "'top'" : "'bottom'") )
            }
            VStack {
                Toggle(isOn: $isVerticalBoundary) {
                    HStack {
                        Text("Use Vertical Line")
                    }
                }
                SettingsDescription("Currently using the " + (isVerticalBoundary ? "X" : "Y") + " axis for people movement" )
            }
        }
    }
}

#Preview {
    Form {
        BoundarySettingsView()
    }
}

import SwiftUI

struct SettingsDescription: View {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
    
    var body: some View {
        Text(description)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(0.5)
            .font(.footnote)
            .padding(.top, 7)
            .padding(.bottom, 3)
    }
}

#Preview {
    SettingsDescription("I vvant to suck your blood")
}

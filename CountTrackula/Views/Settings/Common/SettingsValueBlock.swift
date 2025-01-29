import SwiftUI

struct SettingsValueBlock: View {
    var value: String
    
    init(_ value: String) {
        self.value = value
    }
    
    var body: some View {
        Text(value)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blood)
            .foregroundColor(.bone)
            .fontWeight(.medium)
            .borderRadius(8, corners: .allCorners)
    }
}

#Preview {
    SettingsValueBlock(0.156.formatted(.percent))
}

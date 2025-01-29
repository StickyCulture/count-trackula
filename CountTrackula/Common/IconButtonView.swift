import SwiftUI

struct IconButtonView: View {
    var icon: String
    var size: CGFloat = 50
    var color: Color = .white
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)
                .borderRadius(10, corners: .allCorners)
                .opacity(0.5)
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 0.4)
                .foregroundColor(color.opacity(0.8))
            
        }.padding(5)
    }
}

#Preview {
    ZStack {
        Color.blood
        IconButtonView(icon: "backward.end.alt.fill", size: 100, color: .white)
    }
}

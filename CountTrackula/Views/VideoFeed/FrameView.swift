import SwiftUI

struct FrameView: View {
    var image: CGImage?
    
    var body: some View {
        if let image = image {
            Image(image, scale: 1.0, label: Text("frame"))
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Color.blood
        }
    }
}

#Preview {
    FrameView()
}

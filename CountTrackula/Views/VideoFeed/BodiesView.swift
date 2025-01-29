import SwiftUI
import Vision

struct BodiesView: View {
    var bodies: [UUID:Body]
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(Array(bodies), id: \.key) { (id, body) in
                let rect = VNImageRectForNormalizedRect(
                    body.boundingBox.withNormalizedOrientation(.down),
                    Int(geometry.size.width),
                    Int(geometry.size.height)
                )
                let label = String(body.id)
                let color = body.lastTracked > 0 ? .white : Color.random(seed: body.id * 10)
                let visibility = body.lastTracked > 0 ? 0.2 : 1.0

                Rectangle()
                    .path(in: rect)
                    .stroke(color.opacity(visibility), lineWidth: 3)

                Rectangle()
                    .path(in: rect)
                    .fill(color.opacity(0.5 * visibility))

                Text(label)
                    .position(CGPoint(x: rect.midX, y: rect.midY))
                    .font(.system(size: 20, weight: .light, design: .monospaced))
                    .foregroundColor(.white.opacity(visibility))
            }
        }
    }
}

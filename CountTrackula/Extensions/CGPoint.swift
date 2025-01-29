import Foundation
import SwiftUI

extension CGPoint {
    func rotate(by angle: Angle, around origin: CGPoint) -> CGPoint {
        let dx = self.x - origin.x
        let dy = self.y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx) // in radians
        let newAzimuth = azimuth + angle.radians // convert it to radians

        let newX = origin.x + radius * cos(newAzimuth)
        let newY = origin.y + radius * sin(newAzimuth)
        return CGPoint(x: newX, y: newY)
    }
    
    func denormalized(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
    
    func denormalized(by width: CGFloat, and height: CGFloat) -> CGPoint {
        return self.denormalized(to: CGSize(width: width, height: height))
    }
    
    func clamp(to size: CGSize) -> CGPoint {
        return CGPoint(
            x: min(max(self.x, 0.0), size.width),
            y: min(max(self.y, 0.0), size.height)
        )
    }
    
    func clamp(_ width: CGFloat, _ height: CGFloat) -> CGPoint {
        return self.clamp(to: CGSize(width: width, height: height))
    }
}

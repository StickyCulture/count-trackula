import Foundation

extension CGVector {
    var distance: Double {
        return abs(self.dx * self.dx + self.dy * self.dy).squareRoot()
    }
    
    var direction: Double {
        return atan2(self.dx, self.dy)
    }
}

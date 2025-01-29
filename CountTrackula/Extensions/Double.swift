import Foundation

extension Double {
    func clamp(between: ClosedRange<Double>) -> Double {
        return min(max(self, between.lowerBound), between.upperBound)
    }
}


extension CGFloat {
    func clamp(between: ClosedRange<CGFloat>) -> CGFloat {
        return (self > between.lowerBound ? self : between.lowerBound) < between.upperBound ? self : between.upperBound
    }
}

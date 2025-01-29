import Foundation
import Vision

extension CGRect {
    /** Creates a rectangle with the given center and dimensions
        - parameter center: The center of the new rectangle
        - parameter size: The dimensions of the new rectangle
    */
    init(center: CGPoint, size: CGSize) {
        self.init(cx: center.x, cy: center.y, width: size.width, height: size.height)
    }
    
    /** Creates a rectangle with the given center and dimensions
        - parameter cx: The center x-coordinate of the new rectangle
        - parameter cy: The center y-coordinate of the new rectangle
        - parameter width: The width of the new rectangle
        - parameter height: The height of the new rectangle
    */
    init(cx: CGFloat, cy: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(x: cx - width / 2, y: cy - height / 2, width: width, height: height)
    }
    
    /** the coordinates of this rectangles center */
    var center: CGPoint {
        get { return CGPoint(x: centerX, y: centerY) }
        set { centerX = newValue.x; centerY = newValue.y }
    }
    
    /** the x-coordinate of this rectangles center
        - note: Acts as a settable midX
        - returns: The x-coordinate of the center
     */
    var centerX: CGFloat
        {
        get { return midX }
        set { origin.x = newValue - width * 0.5 }
    }
    
    /** the y-coordinate of this rectangles center
         - note: Acts as a settable midY
         - returns: The y-coordinate of the center
     */
    var centerY: CGFloat
        {
        get { return midY }
        set { origin.y = newValue - height * 0.5 }
    }
    
    func vector(to: CGRect) -> CGVector {
        return CGVector(
            dx: self.midX - to.midX,
            dy: self.midY - to.midY
        )
    }
    
    func distance(to other: CGRect) -> CGFloat {
        return self.vector(to: other).distance
    }
    
    /// Use this to flip CGRect orientation of UI-derived elements to match orientation of Vision/Camera buffers
    /// Current usage should only require `.down` orientation.
    func withNormalizedOrientation(_ orientation: CGImagePropertyOrientation) -> CGRect {
        var translation = CGPoint(x: 0, y: 0)
        var scale = CGPoint(x: 1, y: 1)

        // TODO: handle all orientations
        switch orientation {
        case .down:
            translation.y = 1
            scale.y = -1
        case .downMirrored:
            translation.x = 1
            translation.y = 1
            scale.x = -1
            scale.y = -1
        default:
            break
        }
        
        let transform = CGAffineTransform(translationX: translation.x, y: translation.y)
            .scaledBy(x: scale.x, y: scale.y)
        let newRect = self.applying(transform)
        
        return newRect
    }
}

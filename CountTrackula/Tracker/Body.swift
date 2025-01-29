import Vision

public struct Body {
    var detection: VNDetectedObjectObservation
    /// The bounding box returned by Vision requests will be normalized to a top-left boundary of (0,1) to bottom-right of (1,0)
    var boundingBox: CGRect
    var initialBoundingBox: CGRect?
    var id: Int = 0
    var lastTracked: Int = 0
    
    func hasExceededTrackingTimeout(of maxTimeout: Int, within gradientRegion: CGRect? = nil) -> Bool {
        guard let gradientRegion = gradientRegion else {
            return self.lastTracked > maxTimeout
        }
        
        // get distance between center points
        // gradient center becomes origin for boundingBox position
        let dx = abs(gradientRegion.center.x - self.boundingBox.center.x)
        let dy = abs(gradientRegion.center.y - self.boundingBox.center.y)
        
        // offset the size to account for centered origin
        let width = gradientRegion.width * 0.5
        let height = gradientRegion.height * 0.5
        
        // normalize boundingBox to gradient container
        // and invert so that center is 1 and edges are 0
        let x = 1.0 - dx / width
        let y = 1.0 - dy / height

        // defer to the smallest to induce greater falloff
        let gradient = min(x, y)

        // apply gradient
        return self.lastTracked > Int(CGFloat(maxTimeout) * gradient)
    }
}

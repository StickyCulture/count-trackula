import Foundation

struct Settings {
    // camera
    static var cameraDeviceIndex = Obj<Int>(.cameraDeviceIndex, defaultValue: 0)
    static var cameraZoomFactor = Obj<Double>(.cameraZoomFactor, defaultValue: 1.0)

    // tracking
    static var maxTrackingTimeout = Obj<Int>(.maxTrackingTimeout, defaultValue: 20)
    static var redetectionInterval = Obj<Int>(.redetectionInterval, defaultValue: 60)
    static var trackingConfidence = Obj<Double>(.trackingConfidence, defaultValue: 0.4)
    static var timeoutGradientCenterX = Obj<CGFloat>(.timeoutGradientCenterX, defaultValue: 0.5)
    static var timeoutGradientCenterY = Obj<CGFloat>(.timeoutGradientCenterY, defaultValue: 0.5)
    static var timeoutGradientWidth = Obj<CGFloat>(.timeoutGradientWidth, defaultValue: 1.0)
    static var timeoutGradientHeight = Obj<CGFloat>(.timeoutGradientHeight, defaultValue: 1.0)
    
    // counting
    static var isOutsideOnTop = Obj<Bool>(.isOutsideOnTop, defaultValue: false)
    static var isVerticalBoundary = Obj<Bool>(.isVerticalBoundary, defaultValue: false)
    static var boundaryPosition = Obj<Double>(.boundaryPosition, defaultValue: 0.5)
    static var minimumTravel = Obj<Double>(.minimumTravel, defaultValue: 0.2)
    
    // analytics
    static var analyticsApplication = Obj<String>(.analyticsApplication, defaultValue: "sticky-app-counttrackula")
    static var analyticsInstance = Obj<String>(.analyticsInstance, defaultValue: "default")
    static var analyticsIsDisabled = Obj<Bool>(.analyticsIsDisabled, defaultValue: false)
    static var analyticsIsDevelopment = Obj<Bool>(.isDevelopment, defaultValue: true)
}

extension Settings {
    enum Key: String {
        case cameraDeviceIndex
        case cameraZoomFactor

        case maxTrackingTimeout
        case redetectionInterval
        case trackingConfidence
        case timeoutGradientCenterX
        case timeoutGradientCenterY
        case timeoutGradientWidth
        case timeoutGradientHeight
        
        case isOutsideOnTop
        case isVerticalBoundary
        case boundaryPosition
        case minimumTravel
        
        case analyticsApplication
        case analyticsInstance
        case analyticsIsDisabled
        
        case isDevelopment
    }
    
    struct Obj<T> {
        private var _key: Key
        private var _defaultValue: T

        var key: String {
            return self._key.rawValue
        }

        var value: T {
            get {
                let _value = UserDefaults.standard.value(forKey: self._key.rawValue)
                if _value == nil {
                    return self._defaultValue
                }
                return _value as! T
            }
            
            set {
                UserDefaults.standard.set(newValue, forKey: self.key)
            }
        }
        
        init(_ key: Key, defaultValue: T) {
            self._key = key
            self._defaultValue = defaultValue
        }
    }
}

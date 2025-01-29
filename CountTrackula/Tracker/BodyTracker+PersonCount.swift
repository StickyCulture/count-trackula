import Foundation

extension BodyTracker {
    func handleFinishedTrackingBody(_ body: Body) {
        let isOutsideOnTop = Settings.isOutsideOnTop.value
        let isVerticalBoundary = Settings.isVerticalBoundary.value
        let boundaryPosition = CGFloat(Settings.boundaryPosition.value)
        let minimumTravel = CGFloat(Settings.minimumTravel.value)

        let initialPosition = isVerticalBoundary ? body.initialBoundingBox!.center.x : body.initialBoundingBox!.center.y
        let finalPosition = isVerticalBoundary ? body.boundingBox.center.x : body.boundingBox.center.y

        if (abs(finalPosition - initialPosition) < minimumTravel) {
            print("ignoring body that hasn't moved much")
            if (Analytics.shared.isDevelopment) {
                Analytics.shared.trackError(for: body.id, description: "Not enough movement")
            }
            SoundManager.shared.playSoundEffect(named: "too-short")
            return
        }
        
        let hasCrossedThresholdFromOutside: Bool
        let hasCrossedThresholdFromInside: Bool
        if isOutsideOnTop {
            hasCrossedThresholdFromOutside = initialPosition > boundaryPosition && finalPosition <= boundaryPosition
            hasCrossedThresholdFromInside = initialPosition < boundaryPosition && finalPosition >= boundaryPosition
        } else {
            hasCrossedThresholdFromOutside = initialPosition < boundaryPosition && finalPosition >= boundaryPosition
            hasCrossedThresholdFromInside = initialPosition > boundaryPosition && finalPosition <= boundaryPosition
        }
        
        if hasCrossedThresholdFromOutside {
            print("🌹 person entered")
            Analytics.shared.trackEntrance(for: body.id)
            SoundManager.shared.playSoundEffect(named: "person-enter")
        } else if hasCrossedThresholdFromInside {
            print("🥀 person exited")
            Analytics.shared.trackExit(for: body.id)
            SoundManager.shared.playSoundEffect(named: "person-exit")
        } else {
            print("ignoring body that did not cross the threshold")
            if (Analytics.shared.isDevelopment) {
                Analytics.shared.trackError(for: body.id, description: "Did not cross line")
            }
            SoundManager.shared.playSoundEffect(named: "failed-to-cross")
        }
    }
    
    // daily reset of the body id counter
    func incrementId() {
        let currentDate = Calendar.current.startOfDay(for: Date())
        if !Calendar.current.isDate(self.lastResetDate, inSameDayAs: currentDate) {
            self.nextId = 0
            self.lastResetDate = currentDate
            if (Analytics.shared.isDevelopment) {
                Analytics.shared.trackSystemEvent(description: "Reset ID count")
            }
        }
        self.nextId += 1
    }
}

import Vision
import Network
import UIKit
import AVFoundation
import Foundation
import CoreFoundation

class BodyTracker {
    var bodies: [UUID:Body] = [:]
    var nextId: Int = 0

    var trackingConfidence = Settings.trackingConfidence.value
    var redetectionInterval: Int = Settings.redetectionInterval.value
    var maxTrackingTimeout = Settings.maxTrackingTimeout.value

    var lastResetDate: Date = Calendar.current.startOfDay(for: Date())
    var lastDetectionFrame: Int = 0
    
    var gradientRegion = CGRect(
        cx: Settings.timeoutGradientCenterX.value,
        cy: Settings.timeoutGradientCenterY.value,
        width: Settings.timeoutGradientWidth.value,
        height: Settings.timeoutGradientHeight.value
    ).withNormalizedOrientation(.down)
    
    var detectionRequests = VNDetectHumanRectanglesRequest()
    var trackingSequenceHandler = VNSequenceRequestHandler()
    
    init() {
        detectionRequests.revision = VNDetectHumanRectanglesRequestRevision2
        detectionRequests.upperBodyOnly = false
    }
    
    func handleBuffer(sampleBuffer: CMSampleBuffer?) throws {
        lastDetectionFrame += 1
        
        guard let buffer = sampleBuffer else {
            return
        }
        
        var currentBodies = self.bodies
        
        if bodies.isEmpty || lastDetectionFrame >= redetectionInterval {
            self.trackingSequenceHandler = VNSequenceRequestHandler()
            lastDetectionFrame = 0
            currentBodies = self.detectBodies(in: buffer)
        } else {
            currentBodies = self.trackBodies(in: buffer)
        }
        
        self.bodies = self.determineLoss(among: currentBodies)
    }
    
    func detectBodies(in buffer: CMSampleBuffer) -> [UUID:Body] {
        let imageHandler = VNImageRequestHandler(
            cmSampleBuffer: buffer
        )
        
        do {
            try imageHandler.perform([detectionRequests])
        } catch let error as NSError {
            NSLog("BodyTacker.detectBodies.imageHandler.perform: %@", error)
        }

        // skip if no detections
        guard let detections = detectionRequests.results,
              !detections.isEmpty
        else {
            return self.bodies
        }
        
        var currentBodies: [UUID:Body] = [:]
        var previousBodies: [Body] = self.bodies.map { key, value in
            return value
        }
        
        for detection in detections {
            if Double(detection.confidence) < self.trackingConfidence {
                continue
            }
            
            var currentBody = Body(
                detection: detection,
                boundingBox: detection.boundingBox
            )
            
            // sort (in place) by current detection's distance to all other previously known detections
            // order from far to near so that the nearest candidate is last and can be popped off
            previousBodies.sort(by: { a, b in
                let aDistance = currentBody.boundingBox.distance(to: a.boundingBox)
                let bDistance = currentBody.boundingBox.distance(to: b.boundingBox)
                
                return aDistance > bDistance
            })
            
            if let nearestBody = previousBodies.popLast(),
               currentBody.boundingBox.distance(to: nearestBody.boundingBox) < 0.25
            {
                currentBody = nearestBody
                currentBody.detection = detection
                currentBody.boundingBox = detection.boundingBox
            } else {
                self.incrementId()
                currentBody.id = self.nextId
                currentBody.initialBoundingBox = detection.boundingBox
                SoundManager.shared.playSoundEffect(named: "body-detected")
            }
            
            currentBody.lastTracked = -1
            currentBodies[detection.uuid] = currentBody
        }
        
        for remainingBody in previousBodies {
            currentBodies[remainingBody.detection.uuid] = remainingBody
        }
        
        return currentBodies
    }
        
    func trackBodies(in buffer: CMSampleBuffer) -> [UUID:Body] {
        var trackingRequests = [VNTrackObjectRequest]()
        
        if bodies.isEmpty {
            return self.bodies
        }
        
        for body in self.bodies {
            // do not track ghosts
            guard body.value.lastTracked == 0 else {
                continue
            }
            let tracker = VNTrackObjectRequest(detectedObjectObservation: body.value.detection)
            tracker.trackingLevel = .accurate
            trackingRequests.append(tracker)
        }
        
        do {
            try trackingSequenceHandler.perform(trackingRequests, on: buffer)
        } catch {
            print("BodyTracker.trackBodies: tracking failed for someone")
        }
        
        var currentBodies: [UUID:Body] = [:]
        var previousBodies: [UUID:Body] = self.bodies
        
        for request in trackingRequests {
            // make sure there's results
            guard let results = request.results,
                  let tracking = results.first as? VNDetectedObjectObservation
            else {
                continue
            }

            // high confidence forces more attempts to redetect
            guard tracking.confidence > 0.8 else {
                continue
            }
            
            // match the tracking result to a known body
            guard var knownBody = previousBodies.removeValue(forKey: tracking.uuid) else {
                print("BodyTracker.trackBodies: tracked something that wasn't previously detected...this shouldn't happen")
                continue
            }
            
            knownBody.detection = tracking
            knownBody.boundingBox = tracking.boundingBox
            knownBody.lastTracked = -1
            currentBodies[tracking.uuid] = knownBody
        }
        
        if !previousBodies.isEmpty {
            lastDetectionFrame += redetectionInterval
        }
        
        for remainingBody in previousBodies {
            currentBodies[remainingBody.key] = remainingBody.value
        }
        
        return currentBodies
    }
    
    func determineLoss(among currentBodies: [UUID:Body]) -> [UUID:Body] {
        var remainingBodies: [UUID: Body] = [:]
      
        for var body in currentBodies {
            body.value.lastTracked += 1

            if (body.value.lastTracked == 1) {
                SoundManager.shared.playSoundEffect(named: "body-lost")
            }

            if body.value.hasExceededTrackingTimeout(of: self.maxTrackingTimeout, within: self.gradientRegion) {
                self.handleFinishedTrackingBody(body.value)
                continue
            }

            remainingBodies[body.key] = body.value
        }

        return remainingBodies
    }
}

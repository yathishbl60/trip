#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import MapKit
import SwiftUI
import Foundation

extension CameraModel {
    func transition(to camera: MapCamera) {
        transition(to: .camera(camera), duration: duration(to: camera))
    }

    func transition(to position: MapCameraPosition, duration: Double) {
        withAnimation(reduceMotion ? nil : .smooth(duration: duration)) {
            self.position = position
        }
    }

    /// Small corrections settle quickly; travel and zoom changes get time to remain legible.
    private func duration(to camera: MapCamera) -> Double {
        CameraTransitionTiming.duration(from: animationOrigin, to: camera, maximum: configuration.motion.camera)
    }

    private var animationOrigin: MapCamera {
        isMoving ? sampledCamera : currentCamera
    }
}

/// The largest visible change determines timing; translation, zoom, and orientation do not stack durations.
private nonisolated enum CameraTransitionTiming {
    // Even a tiny correction receives 45% of the configured duration, avoiding a sudden snap.
    static let minimumDurationFraction = 0.45
    // An eightfold distance change (three doublings) receives the full configured duration.
    static let zoomDoublingsForFullDuration = 3.0

    static func duration(from origin: MapCamera, to target: MapCamera, maximum: Double) -> Double {
        let travel = travelFraction(from: origin, to: target)
        let zoom = zoomFraction(from: origin, to: target)
        let orientation = orientationFraction(from: origin, to: target)
        let largestChange = min(max(max(travel, zoom), orientation), 1)
        let durationFraction = minimumDurationFraction + (1 - minimumDurationFraction) * largestChange
        return maximum * durationFraction
    }

    private static func travelFraction(from origin: MapCamera, to target: MapCamera) -> Double {
        let cameraSpan = max(max(origin.distance, target.distance), 1)
        let travelMeters = Coordinate(origin.centerCoordinate).distance(to: Coordinate(target.centerCoordinate))
        return travelMeters / cameraSpan
    }

    private static func zoomFraction(from origin: MapCamera, to target: MapCamera) -> Double {
        let distanceRatio = max(target.distance, 1) / max(origin.distance, 1)
        let doublings = abs(log2(distanceRatio))
        return doublings / zoomDoublingsForFullDuration
    }

    private static func orientationFraction(from origin: MapCamera, to target: MapCamera) -> Double {
        let fullTurnDegrees = 360.0
        let quarterTurnDegrees = fullTurnDegrees / 4
        let halfTurnDegrees = fullTurnDegrees / 2
        let headingChange = abs(target.heading - origin.heading).truncatingRemainder(dividingBy: fullTurnDegrees)
        let shortestTurn = min(headingChange, fullTurnDegrees - headingChange)
        let tiltChange = abs(target.pitch - origin.pitch)
        return max(shortestTurn / halfTurnDegrees, tiltChange / quarterTurnDegrees)
    }
}

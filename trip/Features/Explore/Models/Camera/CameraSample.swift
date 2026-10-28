#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import MapKit
import SwiftUI

nonisolated struct CameraSample: Equatable {
    let center: Coordinate
    let distance: Double
    let heading: Double
    let pitch: Double
    let rect: CGRect

    init(_ context: MapCameraUpdateContext) {
        self.init(context.camera, rect: CGRect(x: context.rect.minX, y: context.rect.minY,
                                              width: context.rect.width, height: context.rect.height))
    }

    init(_ camera: MapCamera, rect: CGRect) {
        center = Coordinate(camera.centerCoordinate)
        distance = camera.distance
        heading = camera.heading
        pitch = camera.pitch
        self.rect = rect
    }

    func differs(from other: Self?, viewport: CGSize,
                 minimumPanDistance: CGFloat = MarkerLayoutPolicy.defaultMinimumPanDistance) -> Bool {
        guard let other else { return true }
        let hasPanned = panDistance(from: other, viewport: viewport) >= minimumPanDistance
        let hasTurned = headingChange(from: other) > CameraProjectionPolicy.orientationChangeDegrees
        let hasTilted = abs(pitch - other.pitch) > CameraProjectionPolicy.orientationChangeDegrees
        let zoomThreshold = max(distance, 1) * CameraProjectionPolicy.relativeDistanceChange
        let hasZoomed = abs(distance - other.distance) > zoomThreshold
        return hasPanned || hasTurned || hasTilted || hasZoomed
    }

    /// Estimate movement only for scheduling; marker coordinates still come from MapProxy.
    private func panDistance(from other: Self, viewport: CGSize) -> CGFloat {
        let worldWidth = MKMapSize.world.width
        let horizontal = abs(rect.midX - other.rect.midX).truncatingRemainder(dividingBy: worldWidth)
        let shortestHorizontal = min(horizontal, worldWidth - horizontal)
        let horizontalPoints = shortestHorizontal * viewport.width / max(rect.width, 1)
        let verticalPoints = abs(rect.midY - other.rect.midY) * viewport.height / max(rect.height, 1)
        return hypot(horizontalPoints, verticalPoints)
    }

    private func headingChange(from other: Self) -> Double {
        let fullTurnDegrees = 360.0
        let change = abs(heading - other.heading).truncatingRemainder(dividingBy: fullTurnDegrees)
        return min(change, fullTurnDegrees - change)
    }
}

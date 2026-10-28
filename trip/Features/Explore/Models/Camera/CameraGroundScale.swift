#if !TRIP_STANDALONE
import MapEngine
#endif
import CoreGraphics
import Foundation
import MapKit
import SwiftUI

/// Keep a projection's ground scale paired with the camera that produced it.
nonisolated struct CameraGroundScale {
    let metersPerPoint: Double
    let measuredCameraDistance: Double
    let measuredPitch: Double
    let viewport: CGSize

    init?(metersPerPoint: Double, camera: MapCamera, viewport: CGSize) {
        guard metersPerPoint.isFinite, metersPerPoint > 0,
              camera.distance.isFinite, camera.distance > 0,
              camera.pitch.isFinite, viewport.width.isFinite, viewport.height.isFinite,
              viewport.width > 0, viewport.height > 0 else { return nil }
        self.metersPerPoint = metersPerPoint
        measuredCameraDistance = camera.distance
        measuredPitch = camera.pitch
        self.viewport = viewport
    }

    func distance(for level: ZoomLevel, camera: MapCamera, viewport: CGSize) -> Double? {
        guard viewport == self.viewport,
              abs(camera.pitch - measuredPitch) < CameraProjectionPolicy.orientationChangeDegrees else { return nil }
        let zoomRatio = level.preferredMetersPerPoint / metersPerPoint
        let estimatedDistance = measuredCameraDistance * zoomRatio
        guard estimatedDistance.isFinite else { return nil }
        return CameraNavigationPolicy.clampedDistance(estimatedDistance)
    }
}

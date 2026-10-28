#if !TRIP_STANDALONE
import MapEngine
#endif
import Foundation

/// Product choices for camera commands. Distances are meters; angles are degrees.
nonisolated enum CameraNavigationPolicy {
    // Keep commands between a close street view and a whole-Earth view.
    static let supportedDistances = 100.0...40_000_000.0
    static let explorationDistance = 1_200.0
    static let explorationPitch = 50.0
    // A selected dot moves at least twice as close, even when collisions created it.
    private static let dotSelectionDistanceFactor = 0.5
    // Ignore near-north/near-flat noise when deciding whether to show Reset Orientation.
    static let orientationTolerance = 1.0
    // Wait until a commanded camera is within 1% (at least one meter) before revealing a sheet selection.
    private static let framingDistanceFraction = 0.01
    private static let minimumFramingTolerance = 1.0
    static let minimumRevealMovementPoints = 1.0

    static func clampedDistance(_ distance: Double) -> Double {
        guard distance.isFinite else { return ZoomLevel.district.distance }
        return min(max(distance, supportedDistances.lowerBound), supportedDistances.upperBound)
    }

    static func distanceForSelectedDot(current: Double, readable: Double) -> Double {
        let closerDistance = current * dotSelectionDistanceFactor
        return max(supportedDistances.lowerBound, min(closerDistance, readable))
    }

    static func framingTolerance(at distance: Double) -> Double {
        max(minimumFramingTolerance, distance * framingDistanceFraction)
    }
}

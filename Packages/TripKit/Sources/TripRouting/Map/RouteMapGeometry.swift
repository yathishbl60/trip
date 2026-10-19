import CoreGraphics
import MapKit

/// Route fitting operates on host-supplied viewport values and never owns the map camera.
public nonisolated enum RouteMapGeometry {
    public static func cameraRect(for bounds: MKMapRect, in nativeViewport: CGRect, exposedViewport: CGRect,
                                  mapSize: CGSize) -> MKMapRect? {
        let viewport = exposedViewport.insetBy(dx: 52, dy: 52)
        guard mapSize.width > 0, mapSize.height > 0, viewport.width > 60, viewport.height > 100,
              !bounds.isNull, bounds.origin.x.isFinite, bounds.origin.y.isFinite,
              bounds.width.isFinite, bounds.height.isFinite else { return nil }
        let latitude = MKMapPoint(x: bounds.midX, y: bounds.midY).coordinate.latitude
        let minimum = 200 * MKMapPointsPerMeterAtLatitude(latitude)
        let scale = max(max(bounds.width, minimum) / viewport.width, max(bounds.height, minimum) / viewport.height)
        // Frame the route in the exposed viewport without moving native map chrome.
        return MKMapRect(x: bounds.midX - (viewport.midX - nativeViewport.minX) * scale,
                         y: bounds.midY - (viewport.midY - nativeViewport.minY) * scale,
                         width: nativeViewport.width * scale, height: nativeViewport.height * scale)
    }

    /// Choose the largest exposed rectangle for bottom sheets and floating iPad sheets.
    public static func exposedFrame(in bounds: CGRect, obstacles: [CGRect]) -> CGRect {
        guard !bounds.isEmpty, !bounds.isNull else { return .zero }
        let candidates = obstacles.reduce([bounds]) { frames, obstacle in
            frames.flatMap { exposedPieces(of: $0, around: obstacle) }
        }
        return candidates.max { $0.width * $0.height < $1.width * $1.height } ?? .zero
    }

    private static func exposedPieces(of bounds: CGRect, around obstacle: CGRect) -> [CGRect] {
        let covered = obstacle.intersection(bounds)
        guard !covered.isNull, !covered.isEmpty else { return [bounds] }
        return [
            CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: covered.minY - bounds.minY),
            CGRect(x: bounds.minX, y: covered.maxY, width: bounds.width, height: bounds.maxY - covered.maxY),
            CGRect(x: bounds.minX, y: bounds.minY, width: covered.minX - bounds.minX, height: bounds.height),
            CGRect(x: covered.maxX, y: bounds.minY, width: bounds.maxX - covered.maxX, height: bounds.height)
        ].filter { !$0.isEmpty }
    }
}

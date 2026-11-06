import CoreGraphics
import TripRouting

extension CameraModel {
    /// Choose the largest exposed rectangle for bottom sheets and floating iPad sheets.
    func exposedFrame(in bounds: CGRect) -> CGRect {
        let obstacles = reservedFrames + [MapViewportPolicy.sheetExclusion(sheetFrame)]
        return RouteMapGeometry.exposedFrame(in: bounds, obstacles: obstacles)
    }
}

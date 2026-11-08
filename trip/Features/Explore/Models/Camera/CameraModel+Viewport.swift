import CoreGraphics
import TripRouting

extension CameraModel {
    /// Zero means the spatial sidebar has been laid out beside the map. Null means geometry is still pending.
    func recordPanelFrame(_ measured: CGRect) -> Bool {
        #if os(visionOS)
        let obstacle = CGRect.zero
        #else
        let obstacle = measured
        #endif
        guard sheetFrame != obstacle else { return false }
        sheetFrame = obstacle
        return true
    }

    /// Choose the largest exposed rectangle around a bottom or side sheet.
    func exposedFrame(in bounds: CGRect) -> CGRect {
        let obstacles = reservedFrames + [MapViewportPolicy.sheetExclusion(sheetFrame)]
        return RouteMapGeometry.exposedFrame(in: bounds, obstacles: obstacles)
    }
}

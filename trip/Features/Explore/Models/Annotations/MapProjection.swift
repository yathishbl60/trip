import MapEngine
import CoreGraphics

/// Plain values may outlive a map callback; MapProxy and its view graph may not.
nonisolated struct MapProjection: Sendable {
    let candidates: [ProjectedPlace]
    let points: [String: CGPoint]
    let locationPoint: CGPoint?
    let viewport: CGRect
    let zoom: ZoomLevel
    let scale: CGFloat
    var routeExclusions: [CGRect] = []
}

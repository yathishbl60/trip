import SwiftUI
import CoreGraphics

/// System regions include their clearance margins; values use the map's global coordinate space.
nonisolated enum MapReservedRegions {
    static func frames(in geometry: GeometryProxy) -> [CGRect] {
        #if os(iOS)
        let origin = geometry.frame(in: .global).origin
        let regions = geometry.reservedRegions(kind: .division, layoutDirectionBehavior: .fixed)
            + geometry.reservedRegions(kind: .occlusion, layoutDirectionBehavior: .fixed)
        return regions.filter(\.isActive).map { $0.frame.offsetBy(dx: origin.x, dy: origin.y) }
        #else
        return []
        #endif
    }
}

import MapEngine
import MapKit
import TripDomain
import SwiftUI

/// Capture values synchronously; the MapProxy never escapes its MapReader callback.
nonisolated struct MapViewportGeometry: Sendable {
    let region: MapCandidateRegion?
    let cells: [MapCandidateRegion]

    @MainActor init(proxy: MapProxy, size: CGSize, center: Coordinate) {
        let points = (0..<16).compactMap { index in
            proxy.convert(CGPoint(x: size.width * CGFloat(index % 4) / 3,
                                  y: size.height * CGFloat(index / 4) / 3), from: .local)
        }
        guard points.count == 16 else { region = nil; cells = []; return }
        region = MapCandidateRegion(corners: [points[0], points[3], points[15], points[12]], center: center.location)
        cells = (0..<9).compactMap { index in
            let start = index / 3 * 4 + index % 3
            return MapCandidateRegion(corners: [points[start], points[start + 1], points[start + 5], points[start + 4]],
                                      center: center.location)
        }
    }
}

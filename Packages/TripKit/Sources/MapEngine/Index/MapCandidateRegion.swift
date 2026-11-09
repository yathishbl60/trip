import MapKit
import CoreLocation

/// An ordered ground polygon captured by a live MapProxy, in one wrapped world copy.
public nonisolated struct MapCandidateRegion: Sendable {
    public let bounds: MKMapRect
    private let points: [MKMapPoint]

    public init?(corners: [CLLocationCoordinate2D], center: CLLocationCoordinate2D) {
        guard corners.count == 4, CLLocationCoordinate2DIsValid(center),
              corners.allSatisfy(CLLocationCoordinate2DIsValid) else { return nil }
        let centerX = MKMapPoint(center).x
        let points = corners.map { MKMapPoint($0) }.map { MKMapPoint(x: Self.wrap($0.x, near: centerX), y: $0.y) }
        guard Self.isConvex(points), let x = points.map(\.x).min(), let y = points.map(\.y).min(),
              let maxX = points.map(\.x).max(), let maxY = points.map(\.y).max(),
              maxX - x < MKMapSize.world.width / 2 else { return nil }
        self.points = points
        bounds = MKMapRect(x: x, y: y, width: maxX - x, height: maxY - y)
    }

    public func contains(_ point: MKMapPoint) -> Bool {
        guard point.x.isFinite, point.y.isFinite else { return false }
        let wrapped = MKMapPoint(x: Self.wrap(point.x, near: bounds.midX), y: point.y)
        guard (bounds.minX...bounds.maxX).contains(wrapped.x), (bounds.minY...bounds.maxY).contains(wrapped.y) else { return false }
        var side = 0.0
        for index in points.indices {
            let cross = Self.cross(points[index], points[(index + 1) % 4], wrapped)
            if cross == 0 { continue }
            if side != 0, (side > 0) != (cross > 0) { return false }
            side = cross
        }
        return true
    }

    private static func isConvex(_ points: [MKMapPoint]) -> Bool {
        guard points.allSatisfy({ $0.x.isFinite && $0.y.isFinite }) else { return false }
        let turns = points.indices.map { cross(points[$0], points[($0 + 1) % 4], points[($0 + 2) % 4]) }
        return turns.allSatisfy { $0 > 0 } || turns.allSatisfy { $0 < 0 }
    }

    private static func cross(_ a: MKMapPoint, _ b: MKMapPoint, _ c: MKMapPoint) -> Double {
        (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
    }

    private static func wrap(_ x: Double, near center: Double) -> Double {
        let world = MKMapSize.world.width
        return x + ((center - x) / world).rounded() * world
    }
}

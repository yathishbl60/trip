import MapKit
import Foundation
import TripDomain
import CryptoKit

public struct DirectionsRoute: Identifiable {
    public let id: String
    public let name: String
    public let estimate: DirectionsEstimate
    public let polyline: MKPolyline
    public let steps: [DirectionsStep]
    public let notices: [String]
    public let hasTolls: Bool
    public let hasHighways: Bool
    private let labelCoordinates: [Coordinate]

    public init(name: String, estimate: DirectionsEstimate, polyline: MKPolyline,
                steps: [DirectionsStep], notices: [String], hasTolls: Bool, hasHighways: Bool) {
        self.id = Self.identifier(polyline)
        self.name = name
        self.estimate = estimate
        self.polyline = polyline
        self.steps = steps
        self.notices = notices
        self.hasTolls = hasTolls
        self.hasHighways = hasHighways
        labelCoordinates = Self.makeLabelCoordinates(polyline)
    }

    func labelCoordinate(index: Int) -> Coordinate {
        guard !labelCoordinates.isEmpty else { return Coordinate(latitude: 0, longitude: 0) }
        return labelCoordinates[min(max(index, 0), labelCoordinates.count - 1)]
    }

    private static func makeLabelCoordinates(_ polyline: MKPolyline) -> [Coordinate] {
        guard polyline.pointCount > 0 else { return [] }
        let fractions = [0.55, 0.3, 0.8]
        let last = polyline.pointCount - 1
        return fractions.map { fraction in
            Coordinate(polyline.points()[min(Int(Double(last) * fraction), last)].coordinate)
        }
    }

    private static func identifier(_ polyline: MKPolyline) -> String {
        var hasher = SHA256()
        let points = UnsafeBufferPointer(start: polyline.points(), count: polyline.pointCount)
        var values: [UInt64] = []
        values.reserveCapacity(2_048)
        for point in points {
            values.append(point.x.bitPattern.littleEndian)
            values.append(point.y.bitPattern.littleEndian)
            if values.count == 2_048 {
                values.withUnsafeBytes { hasher.update(bufferPointer: $0) }
                values.removeAll(keepingCapacity: true)
            }
        }
        values.withUnsafeBytes { hasher.update(bufferPointer: $0) }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }
}

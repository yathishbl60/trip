import MapKit
import Foundation

extension DirectionsRoute {
    public static func alternatives(_ responses: [DirectionsResponse], arrival: (TimeInterval) -> Date) throws -> [Self] {
        let legs = responses.compactMap { response -> [MKRoute]? in
            guard case .routes(let routes) = response else { return nil }
            return Array(routes.lazy.filter { $0.polyline.pointCount > 1 }.prefix(3))
        }
        guard !legs.isEmpty, legs.allSatisfy({ !$0.isEmpty }) else { throw DirectionsFailure.unavailable }
        let count = legs.map(\.count).max() ?? 1
        var identifiers: Set<String> = []
        return (0..<count).map { index in
            let combination = legs.map { $0[min(index, $0.count - 1)] }
            let duration = combination.reduce(0) { $0 + $1.expectedTravelTime }
            return Self(legs: combination, arrival: arrival(duration))
        }.filter { identifiers.insert($0.id).inserted }
    }

    private init(legs: [MKRoute], arrival: Date) {
        let pointCount = legs.reduce(0) { $0 + $1.polyline.pointCount }
        var points: [MKMapPoint] = []
        points.reserveCapacity(pointCount)
        for route in legs {
            points.append(contentsOf: UnsafeBufferPointer(start: route.polyline.points(), count: route.polyline.pointCount))
        }
        let estimate = DirectionsEstimate(travelTime: legs.reduce(0) { $0 + $1.expectedTravelTime },
                                          distance: legs.reduce(0) { $0 + $1.distance }, arrival: arrival)
        self.init(name: legs.map(\.name).joined(separator: " → "), estimate: estimate,
                  polyline: MKPolyline(points: points, count: points.count),
                  steps: legs.flatMap(\.steps).enumerated().compactMap(DirectionsStep.init),
                  notices: Array(Set(legs.flatMap(\.advisoryNotices))).sorted(),
                  hasTolls: legs.contains(where: \.hasTolls), hasHighways: legs.contains(where: \.hasHighways))
    }
}

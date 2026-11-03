import Foundation
import MapKit

nonisolated enum BenchmarkFixtures {
    static func projected() -> [ProjectedPlace] {
        (0..<2_000).map { index in
            let place = Place(id: "place-\(index)", name: "Place \(index)", coordinate: .bangkok,
                              category: .hotel, importance: Double(index % 100) / 100, rating: 4.5, reviews: 100)
            return ProjectedPlace(place: place, point: CGPoint(x: (index * 73) % 1_600, y: (index * 137) % 1_200))
        }
    }

    static func places(_ count: Int, extent: Double) -> [Place] {
        (0..<count).map { index in
            let latitude = 13.75 + (Double((index * 71) % 10_000) / 10_000 - 0.5) * extent
            let longitude = 100.55 + (Double((index * 137) % 10_000) / 10_000 - 0.5) * extent
            return Place(id: "place-\(index)", name: "Place \(index)",
                         coordinate: Coordinate(latitude: latitude, longitude: longitude),
                         category: .hotel, importance: 0.5, rating: nil, reviews: nil)
        }
    }

    static func regions() -> [MKMapRect] {
        (0..<100).map { index in
            let point = MKMapPoint(CLLocationCoordinate2D(latitude: 13.7 + Double(index % 10) * 0.01,
                                                        longitude: 100.5 + Double(index / 10) * 0.01))
            let width = 5_000 * MKMapPointsPerMeterAtLatitude(13.75)
            return MKMapRect(x: point.x - width / 2, y: point.y - width / 2, width: width, height: width)
        }
    }
}

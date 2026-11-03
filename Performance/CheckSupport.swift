import Foundation
import CoreGraphics

nonisolated struct CheckFailure: Error, CustomStringConvertible {
    let description: String
}

nonisolated func require(_ condition: @autoclosure () -> Bool, _ message: String,
                        file: StaticString = #fileID, line: UInt = #line) throws {
    guard condition() else { throw CheckFailure(description: "\(file):\(line): \(message)") }
}

nonisolated enum CheckFixtures {
    static func place(_ id: String, name: String? = nil, longitude: Double = 100.5) -> Place {
        Place(id: id, name: name ?? "Place \(id)",
              coordinate: Coordinate(latitude: 13.75, longitude: longitude),
              category: .hotel, importance: 0.8, rating: 4.5, reviews: 100)
    }

    static func request(_ points: [ProjectedPlace], zoom: ZoomLevel, frame: Int = 0) -> LayoutRequest {
        LayoutRequest(candidates: points, viewport: CGRect(x: 0, y: 0, width: 1_024, height: 768),
                      exclusions: [CGRect(x: 12, y: 0, width: 72, height: 136)], zoom: zoom, scale: 1.5,
                      selectedID: "1999", generation: frame, isSettled: frame % 3 == 0)
    }

    static func candidates(_ frame: Int) -> [ProjectedPlace] {
        (0..<2_000).map { index in
            let point = CGPoint(x: (index * 73 + frame) % 1_024, y: (index * 137 + frame * 2) % 768)
            return ProjectedPlace(place: place("\(index)"), point: point)
        }
    }

    static func worldPlaces(_ count: Int) -> [Place] {
        (0..<count).map { index in
            let longitude = Double((index * 137) % 36_000) / 100 - 180
            let latitude = Double((index * 71) % 16_000) / 100 - 80
            return Place(id: "world-\(index)", name: "Place \(index)",
                         coordinate: Coordinate(latitude: latitude, longitude: longitude),
                         category: index.isMultiple(of: 2) ? .hotel : .cafe,
                         importance: 0.5, rating: nil, reviews: nil)
        }
    }
}

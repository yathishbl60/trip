import Foundation
import MapKit

enum SpatialChecks {
    static func grid() throws {
        var grid = CollisionGrid()
        var occupied: [CGRect] = []
        for index in 0..<3_000 {
            let rect = CGRect(x: (index * 137) % 2_048 - 1_024, y: (index * 79) % 2_048 - 1_024,
                              width: index % 140 + 1, height: index % 160 + 1)
            let expected = occupied.contains { $0.intersects(rect) }
            try require(grid.intersects(rect, ignoring: "query") == expected, "Spatial hash disagrees with full scan")
            grid.insert(rect, id: "\(index)")
            occupied.append(rect)
        }
        var own = CollisionGrid()
        own.insert(CGRect(x: 0, y: 0, width: 44, height: 44), id: "owner")
        try require(!own.intersects(CGRect(x: 0, y: 0, width: 40, height: 40), ignoring: "owner"), "Owner not ignored")
    }

    static func wrapping() throws {
        let east = MapCandidate(CheckFixtures.place("east", longitude: 179.99))
        let west = MapCandidate(CheckFixtures.place("west", longitude: -179.99))
        let rect = MKMapRect(x: east.point.x - 100_000, y: east.point.y - 100_000, width: 200_000, height: 200_000)
        try require(east.isNear(rect) && west.isNear(rect), "Antimeridian candidate missing")
        try require(!MapCandidate(CheckFixtures.place("far", longitude: 0)).isNear(rect), "Distant candidate included")
        try require(east.place.coordinate.distance(to: west.place.coordinate) < 3_000, "Wrapped distance incorrect")
        let region = MKCoordinateRegion(center: east.place.coordinate.location,
                                        span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        try require(SearchArea(region).contains(west.place.coordinate), "Local search does not wrap")
    }

    static func searchAndZoom() throws {
        let narrow = MKCoordinateRegion(center: Coordinate.bangkok.location,
                                       span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        let wide = MKCoordinateRegion(center: narrow.center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 1))
        try require(SearchArea(narrow) != SearchArea(wide), "Search cache ignores viewport shape")
        for previous in ZoomLevel.allCases {
            try require(ZoomLevel.resolve(metersPerPoint: .nan, previous: previous) == previous, "Invalid zoom changed mode")
        }
        try require(ZoomLevel.resolve(metersPerPoint: 3.5, previous: .street) == .street, "Street hysteresis lost")
        try require(ZoomLevel.resolve(metersPerPoint: 3.5, previous: .district) == .district, "Medium zoom hysteresis lost")
    }
}

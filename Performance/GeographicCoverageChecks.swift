import MapKit

enum GeographicCoverageChecks {
    static func run() throws {
        try balancedCoverage()
        try wrappedFootprint()
        try rotatedFootprint()
        print("PASS: geographic coverage retains sparse cells, selection, and wrapped viewport membership")
    }

    private static func balancedCoverage() throws {
        let cells = [try region(west: 100, east: 101), try region(west: 101, east: 102)]
        let dense = (0..<100).map { place("dense-\($0)", longitude: 100.5, importance: 1) }
        let sparse = (0..<10).map { place("sparse-\($0)", longitude: 101.5, importance: 0) }
        let external = place("selection", longitude: -120, importance: 0)
        let index = GeographicIndex(dense + sparse)
        let results = index.candidates(in: .world, categories: [], center: dense[0].coordinate,
                                      selected: external, visibleIDs: [], limit: 20, coverage: cells)
        try require(results.count == 20 && Set(results.map { $0.place.id }).count == 20, "Coverage changed budget or duplicated IDs")
        try require(results.first?.place.id == external.id, "Coverage displaced the selected place")
        try require(results.filter { $0.place.id.hasPrefix("sparse") }.count >= 5, "Dense cell consumed sparse cell's reservation")
        let reversed = GeographicIndex(Array((dense + sparse).reversed())).candidates(in: .world, categories: [],
            center: dense[0].coordinate, selected: external, visibleIDs: [], limit: 20, coverage: cells)
        try require(results.map { $0.place.id } == reversed.map { $0.place.id }, "Coverage depends on insertion order")
    }

    private static func wrappedFootprint() throws {
        let footprint = try region(west: 179, east: -179, center: 180)
        try require(footprint.contains(MKMapPoint(Coordinate(latitude: 13.5, longitude: 179.5).location)), "Lost eastern date-line place")
        try require(footprint.contains(MKMapPoint(Coordinate(latitude: 13.5, longitude: -179.5).location)), "Lost western date-line place")
        try require(!footprint.contains(MKMapPoint(Coordinate.bangkok.location)), "Wrapped footprint included another continent")
    }

    private static func rotatedFootprint() throws {
        let corners = [(14.0, 101.0), (13.5, 102.0), (13.0, 101.0), (13.5, 100.0)]
            .map { Coordinate(latitude: $0.0, longitude: $0.1).location }
        guard let region = MapCandidateRegion(corners: corners, center: Coordinate(latitude: 13.5, longitude: 101).location) else {
            throw CheckFailure(description: "Valid rotated footprint rejected")
        }
        try require(region.contains(MKMapPoint(Coordinate(latitude: 13.5, longitude: 101).location)), "Rotated center rejected")
        try require(!region.contains(MKMapPoint(Coordinate(latitude: 13.9, longitude: 101.9).location)), "Offscreen bounding-box corner accepted")
        try require(MapCandidateRegion(corners: [corners[0], corners[2], corners[1], corners[3]], center: corners[0]) == nil,
                    "Self-intersecting footprint accepted")
    }

    private static func region(west: Double, east: Double, center: Double = 101) throws -> MapCandidateRegion {
        let corners = [(14.0, west), (14.0, east), (13.0, east), (13.0, west)]
            .map { Coordinate(latitude: $0.0, longitude: $0.1).location }
        guard let region = MapCandidateRegion(corners: corners, center: Coordinate(latitude: 13.5, longitude: center).location) else {
            throw CheckFailure(description: "Valid coverage region rejected")
        }
        return region
    }

    private static func place(_ id: String, longitude: Double, importance: Double) -> Place {
        Place(id: id, name: id, coordinate: Coordinate(latitude: 13.5, longitude: longitude),
              category: .museum, importance: importance, rating: nil, reviews: nil)
    }
}

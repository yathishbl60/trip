import Foundation
import MapKit

enum IndexChecks {
    static func run() throws {
        let places = CheckFixtures.worldPlaces(10_000)
            + [CheckFixtures.place("east", longitude: 180), CheckFixtures.place("west", longitude: -180)]
        let index = GeographicIndex(places)
        let all = places.map(MapCandidate.init)
        for frame in 0..<300 {
            let center = all[(frame * 71) % all.count].point
            let rect = MKMapRect(x: center.x - Double(frame % 9) * 500_000,
                                y: center.y - 1_000_000, width: 3_000_000, height: 2_000_000)
            let categories: Set<PlaceCategory> = frame.isMultiple(of: 2) ? [.hotel] : []
            try compare(index, all, rect, categories)
        }
        try boundaries(index, count: places.count)
        try GeographicCandidateChecks.run()
    }

    private static func compare(_ index: GeographicIndex, _ all: [MapCandidate],
                                _ bounds: MKMapRect, _ categories: Set<PlaceCategory>) throws {
        let expected = all.filter { $0.isNear(bounds) && (categories.isEmpty || categories.contains($0.place.category)) }
        let actual = index.query(bounds, categories: categories)
        let identifiers = Set(actual.map { $0.place.id })
        try require(identifiers == Set(expected.map { $0.place.id }), "Geographic index disagrees with full scan")
        try require(identifiers.count == actual.count, "Geographic query duplicated an ID")
    }

    private static func boundaries(_ index: GeographicIndex, count: Int) throws {
        try require(index.query(.world, categories: []).count == count, "World query omitted places")
        try require(index.query(nil, categories: []).count == count, "High-pitch fallback omitted places")
        let invalid = [MKMapRect.null, MKMapRect(x: .nan, y: 0, width: 1, height: 1),
                       MKMapRect(x: 0, y: 0, width: 0, height: 1),
                       MKMapRect(x: 0, y: 0, width: 1, height: -1),
                       MKMapRect(x: 0, y: 0, width: .infinity, height: 1)]
        let candidate = MapCandidate(CheckFixtures.place("bounds"))
        for rect in invalid {
            try require(index.query(rect, categories: []).isEmpty, "Invalid bounds returned places")
            try require(!candidate.isNear(rect), "Public proximity check accepted invalid bounds")
        }
        try require(GeographicIndex().query(.world, categories: []).isEmpty, "Empty index is not empty")
    }
}

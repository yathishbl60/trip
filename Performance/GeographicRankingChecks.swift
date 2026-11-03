import CoreLocation
import MapKit

enum GeographicRankingChecks {
    static func run() throws {
        let places = CheckFixtures.worldPlaces(2_000)
            + [place("tie-a", score: 0.8), place("tie-b", score: 0.8), place("invalid", score: .nan)]
        let index = GeographicIndex(places)
        for limit in [-1, 0, 1, 2, 40, 600, 5_000] {
            try compare(index, limit: limit, selected: places.last, visible: [places[50].id])
        }
        try duplicateUpdates()
        try invalidCenter(index)
        print("PASS: bounded geographic ranking matches full sort with ties, duplicate updates, and selection")
    }

    private static func compare(_ index: GeographicIndex, limit: Int, selected: Place?, visible: Set<String>) throws {
        let center = Coordinate.bangkok
        let expected = reference(index.query(nil, categories: []), center: center,
                                 selected: selected, visible: visible, limit: limit)
        let actual = index.candidates(in: nil, categories: [], center: center,
                                      selected: selected, visibleIDs: visible, limit: limit)
        try require(actual.map { $0.place.id } == expected.map { $0.place.id }, "Bounded ranking differs from full sort")
        try require(Set(actual.map { $0.place.id }).count == actual.count, "Duplicate consumed a projection slot")
        for (result, oracle) in zip(actual, expected) {
            try require(result.place.coordinate == oracle.place.coordinate, "Duplicate retained the wrong coordinate")
        }
    }

    private static func reference(_ candidates: [MapCandidate], center: Coordinate,
                                  selected: Place?, visible: Set<String>, limit: Int) -> [MapCandidate] {
        var candidates = candidates
        if let selected, !candidates.contains(where: { $0.place.id == selected.id }) { candidates.append(MapCandidate(selected)) }
        let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let ranked = candidates.map {
            RankedMapCandidate(candidate: $0, center: location, selectedID: selected?.id, visibleIDs: visible)
        }.sorted(by: RankedMapCandidate.precedes)
        var seen: Set<String> = []
        return ranked.filter { seen.insert($0.id).inserted }.prefix(max(0, limit)).map(\.candidate)
    }

    private static func duplicateUpdates() throws {
        let places = [place("a", score: 0.1, longitude: 100.0), place("b", score: 0.4, longitude: 100.1),
                      place("c", score: 0.3, longitude: 100.2), place("d", score: 0.5, longitude: 100.3),
                      place("b", score: 0.9, longitude: 100.4), place("a", score: 1.0, longitude: 100.5),
                      place("c", score: 1.1, longitude: 100.6), place("a", score: 0.2, longitude: 100.7)]
        for limit in [1, 2, 3, 8] {
            try compare(GeographicIndex(places), limit: limit, selected: nil, visible: [])
            try compare(GeographicIndex(places), limit: limit, selected: places[0], visible: ["c"])
        }
    }

    private static func invalidCenter(_ index: GeographicIndex) throws {
        let result = index.candidates(in: .world, categories: [], center: Coordinate(latitude: .nan, longitude: 0),
                                      selected: nil, visibleIDs: [], limit: 40)
        try require(result.isEmpty, "Invalid center entered the ranking comparator")
    }

    private static func place(_ id: String, score: Double, longitude: Double = 100.5) -> Place {
        Place(id: id, name: id, coordinate: Coordinate(latitude: 13.75, longitude: longitude),
              category: .hotel, importance: score, rating: nil, reviews: nil)
    }
}

import MapKit

enum GeographicCandidateChecks {
    static func run() throws {
        let places = (0..<1_000).map { CheckFixtures.place("place-\($0)") }
        let index = GeographicIndex(places)
        let selected = places[999]
        let candidates = index.candidates(in: .world, categories: [], center: selected.coordinate,
                                           selected: selected, visibleIDs: [places[500].id], limit: 40)
        try require(candidates.count == 40 && candidates.first?.place.id == selected.id, "Projection cap lost selection")
        try require(candidates[1].place.id == places[500].id, "Projection cap discarded a visible place")
        let repeated = index.candidates(in: .world, categories: [], center: selected.coordinate,
                                        selected: selected, visibleIDs: [places[500].id], limit: 40)
        try require(candidates.map { $0.place.id } == repeated.map { $0.place.id }, "Candidate cap is not deterministic")
        try externalSelection(index, selected: selected)
        try GeographicRankingChecks.run()
        print("PASS: bounded projection candidates retain selection, continuity, and external places")
    }

    private static func externalSelection(_ index: GeographicIndex, selected: Place) throws {
        let external = CheckFixtures.place("external", longitude: -120)
        let result = index.candidates(in: .null, categories: [.park], center: external.coordinate,
                                      selected: external, visibleIDs: [], limit: 40)
        try require(result.map { $0.place.id } == [external.id], "Selection outside the catalog/filter was omitted")
        let empty = index.candidates(in: .world, categories: [], center: selected.coordinate,
                                     selected: selected, visibleIDs: [], limit: 0)
        try require(empty.isEmpty, "Zero projection budget returned candidates")
    }
}

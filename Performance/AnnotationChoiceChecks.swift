import CoreGraphics

@MainActor enum AnnotationChoiceChecks {
    static func run() throws {
        let model = LayoutModel()
        defer { model.stop() }
        let origin = CGPoint(x: 500, y: 400)
        let first = CheckFixtures.place("first")
        model.candidates = [
            ProjectedPlace(place: first, point: origin),
            ProjectedPlace(place: CheckFixtures.place("same-coordinate"), point: origin),
            ProjectedPlace(place: CheckFixtures.place("nearby"), point: CGPoint(x: 520, y: 400)),
            ProjectedPlace(place: CheckFixtures.place("beneath-card"), point: CGPoint(x: 575, y: 400)),
            ProjectedPlace(place: CheckFixtures.place("separate"), point: CGPoint(x: 700, y: 400))
        ]
        model.apply([MarkerPlacement(place: first, style: .card)], scale: 1, reduceMotion: true)
        guard let marker = model.markers.first else { throw CheckFailure(description: "Missing marker") }
        let ids = Set(model.choices(for: marker).map(\.id))
        try require(ids == ["first", "same-coordinate", "nearby", "beneath-card"], "Hidden places are not selectable")
        print("PASS: coincident, touch-adjacent, and obscured places remain reachable without moving their coordinates")
    }
}

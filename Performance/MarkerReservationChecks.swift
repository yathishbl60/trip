import CoreGraphics

enum MarkerReservationChecks {
    static func run(_ engine: MarkerLayoutEngine) async throws {
        try await crossedEnvelopes(engine)
        try await entriesAndPromotions(engine)
        try await currentCollisions(engine)
        try await exclusions(engine)
        try await MarkerGestureContinuityChecks.run(engine)
        print("PASS: crossed morph envelopes preserve existing artwork while entries, growth, and current collisions remain protected")
    }

    private static func crossedEnvelopes(_ engine: MarkerLayoutEngine) async throws {
        let points = MarkerReservationFixtures.candidates(separation: 100)
        let reservations = points.map { MarkerReservationFixtures.cardReservation($0) }
        for previous in [MarkerStyle.thumbnail, .card] {
            let history = Dictionary(uniqueKeysWithValues: points.map { ($0.place.id, previous) })
            let request = MarkerReservationFixtures.request(points, zoom: .district, previous: history, reservations: reservations)
            let result = try await engine.arrange(request)
            try require(result.map(\.style) == [.thumbnail, .thumbnail],
                        "Crossed animation envelopes concealed retained or shrinking thumbnails")
        }
    }

    private static func entriesAndPromotions(_ engine: MarkerLayoutEngine) async throws {
        let point = MarkerReservationFixtures.candidates(separation: 100)[0]
        let cover = MarkerReservation(id: "fading", rect: CGRect(x: 300, y: 300, width: 200, height: 200))
        let entry = MarkerReservationFixtures.request([point], zoom: .street, reservations: [cover], settled: true)
        let blocked = try await engine.arrange(entry)
        try require(blocked.isEmpty, "New artwork occupied a foreign fading envelope")
        let edge = MarkerReservation(id: "fading", rect: CGRect(x: 420, y: 360, width: 20, height: 80))
        let growth = MarkerReservationFixtures.request([point], zoom: .street, previous: ["a": .dot],
                                                       reservations: [edge], settled: true)
        let retained = try await engine.arrange(growth)
        try require(retained.first?.style == .dot, "A promotion overlapped a foreign fading envelope")
    }

    private static func currentCollisions(_ engine: MarkerLayoutEngine) async throws {
        let points = MarkerReservationFixtures.candidates(separation: 30)
        let history: [String: MarkerStyle] = ["a": .thumbnail, "b": .thumbnail]
        for selected in [String?.none, "b"] {
            let request = MarkerReservationFixtures.request(points, zoom: .district, previous: history,
                                                            reservations: points.map { MarkerReservationFixtures.cardReservation($0) },
                                                            selectedID: selected)
            let result = try await engine.arrange(request)
            try require(result.map { $0.place.id } == [selected ?? "a"],
                        "Animation continuity bypassed current collisions or selected-place priority")
        }
    }

    private static func exclusions(_ engine: MarkerLayoutEngine) async throws {
        let point = MarkerReservationFixtures.candidates(separation: 100)[0]
        let request = LayoutRequest(candidates: [point], viewport: CGRect(x: 0, y: 0, width: 1_024, height: 768),
                                    exclusions: [CGRect(x: 300, y: 300, width: 200, height: 200)], zoom: .district,
                                    scale: 1, selectedID: "a", generation: 0, isSettled: false, previous: ["a": .thumbnail])
        let result = try await engine.arrange(request)
        try require(result.isEmpty, "Retained artwork ignored a hard map-chrome exclusion")
    }
}

nonisolated enum MarkerReservationFixtures {
    static func candidates(separation: CGFloat, offset: CGFloat = 0) -> [ProjectedPlace] {
        [candidate("a", x: 400 + offset, importance: 1), candidate("b", x: 400 + offset + separation, importance: 0.9)]
    }

    private static func candidate(_ id: String, x: CGFloat, importance: Double) -> ProjectedPlace {
        let place = Place(id: id, name: id, coordinate: .bangkok, category: .hotel,
                          importance: importance, rating: nil, reviews: nil)
        return ProjectedPlace(place: place, point: CGPoint(x: x, y: 400))
    }

    static func cardReservation(_ candidate: ProjectedPlace) -> MarkerReservation {
        let rect = MarkerGeometry(style: .card, scale: 1).bounds(at: candidate.point)
        let clearance = MarkerLayoutPolicy.steadyClearance
        return MarkerReservation(id: candidate.place.id, rect: rect.insetBy(dx: -clearance, dy: -clearance))
    }

    static func request(_ points: [ProjectedPlace], zoom: ZoomLevel, previous: [String: MarkerStyle] = [:],
                        reservations: [MarkerReservation] = [], selectedID: String? = nil, settled: Bool = false) -> LayoutRequest {
        LayoutRequest(candidates: points, viewport: CGRect(x: 0, y: 0, width: 1_024, height: 768), exclusions: [],
                      zoom: zoom, scale: 1, selectedID: selectedID, generation: 0, isSettled: settled,
                      previous: previous, reservations: reservations)
    }
}

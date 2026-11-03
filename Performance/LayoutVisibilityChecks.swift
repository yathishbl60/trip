import CoreGraphics

enum LayoutVisibilityChecks {
    static func run(_ engine: MarkerLayoutEngine) async throws {
        for zoom in ZoomLevel.allCases {
            try await visibleBudget(engine, zoom: zoom, x: -160)
        }
        try await visibleBudget(engine, zoom: .street, x: -60, settled: false)
        try await customLadder(engine)
        try await selectedFallback(engine)
        try await edgeOverlap(engine)
        print("PASS: offscreen candidates preserve the visible budget at every zoom and during movement")
    }

    private static func visibleBudget(_ engine: MarkerLayoutEngine, zoom: ZoomLevel,
                                      x: CGFloat, settled: Bool = true) async throws {
        let input = request(zoom: zoom, x: x, settled: settled)
        let result = try await engine.arrange(input)
        try require(result.map { $0.place.id } == ["visible"], "Offscreen place exhausted the visible candidate budget")
    }

    private static func customLadder(_ engine: MarkerLayoutEngine) async throws {
        var input = request(zoom: .street, x: -60)
        input.policy = MarkerLayoutPolicy(markerLimit: 1, candidateLimit: 1, appearances: [.street: [.thumbnail]])
        let result = try await engine.arrange(input)
        try require(result.first?.place.id == "visible", "Candidate eligibility ignored the configured appearance ladder")
    }

    private static func selectedFallback(_ engine: MarkerLayoutEngine) async throws {
        let input = request(zoom: .region, x: -60, selectedID: "offscreen")
        let result = try await engine.arrange(input)
        try require(result.first?.place.id == "visible", "Unreadable selected label consumed the visible candidate budget")
    }

    private static func edgeOverlap(_ engine: MarkerLayoutEngine) async throws {
        let card = try await engine.arrange(request(zoom: .street, x: -60))
        try require(card.first?.place.id == "offscreen" && card.first?.style == .card,
                    "A partially visible card was removed before collision layout")
        let dot = try await engine.arrange(request(zoom: .region, x: -10))
        try require(dot.first?.place.id == "offscreen", "An edge-overlapping dot was discarded")
    }

    private static func request(zoom: ZoomLevel, x: CGFloat, settled: Bool = true,
                                selectedID: String? = nil) -> LayoutRequest {
        let candidates = [candidate("offscreen", x: x, importance: 2), candidate("visible", x: 200, importance: 0.8)]
        return LayoutRequest(candidates: candidates, viewport: CGRect(x: 0, y: 0, width: 400, height: 800),
                             exclusions: [], zoom: zoom, scale: 1.5, selectedID: selectedID, generation: 0,
                             isSettled: settled, policy: MarkerLayoutPolicy(markerLimit: 1, candidateLimit: 1,
                                                                          selectionStyle: selectedID == nil ? nil : .card))
    }

    private static func candidate(_ id: String, x: CGFloat, importance: Double) -> ProjectedPlace {
        let place = Place(id: id, name: id, coordinate: .bangkok, category: .hotel,
                          importance: importance, rating: nil, reviews: nil)
        return ProjectedPlace(place: place, point: CGPoint(x: x, y: 400))
    }
}

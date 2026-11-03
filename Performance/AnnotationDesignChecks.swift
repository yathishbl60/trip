import Foundation
import CoreGraphics

enum AnnotationDesignChecks {
    static func run() async throws {
        let engine = MarkerLayoutEngine()
        try await selection(engine)
        try await clipping(engine)
        try await obstruction(engine)
        try await selectedFallback(engine)
        print("PASS: zoom-consistent selection, optional promotion, edge fallback, and collision protection")
    }

    private static func selection(_ engine: MarkerLayoutEngine) async throws {
        let candidate = ProjectedPlace(place: CheckFixtures.place("1999"), point: CGPoint(x: 500, y: 400))
        var request = CheckFixtures.request([candidate], zoom: .region)
        let selected = try await engine.arrange(request)
        try require(selected.first?.style == .dot, "Selection bypassed the overview's dot appearance")
        request.policy = MarkerLayoutPolicy(selectionStyle: .card)
        let card = try await engine.arrange(request)
        try require(card.first?.style == .card, "Configured selection style was ignored")
    }

    private static func clipping(_ engine: MarkerLayoutEngine) async throws {
        let edges = [CGPoint(x: 10, y: 400), CGPoint(x: 1_014, y: 400),
                     CGPoint(x: 500, y: 10), CGPoint(x: 500, y: 758)]
        for point in edges {
            let candidate = ProjectedPlace(place: CheckFixtures.place("1999"), point: point)
            var request = CheckFixtures.request([candidate], zoom: .region)
            request.policy = MarkerLayoutPolicy(selectionStyle: .card)
            let result = try await engine.arrange(request)
            try require(result.first?.style == .thumbnail, "Selected label did not fall back to a compact photo at an edge")
        }
    }

    private static func obstruction(_ engine: MarkerLayoutEngine) async throws {
        let candidate = ProjectedPlace(place: CheckFixtures.place("1999"), point: CGPoint(x: 500, y: 400))
        var request = CheckFixtures.request([candidate], zoom: .region)
        request.policy = MarkerLayoutPolicy(selectionStyle: .card)
        request.reservations = [MarkerReservation(id: "neighbor", rect: CGRect(x: 580, y: 350, width: 50, height: 100))]
        let result = try await engine.arrange(request)
        try require(result.first?.style == .thumbnail, "Selected label did not fall back around a neighbor")
    }

    private static func selectedFallback(_ engine: MarkerLayoutEngine) async throws {
        let candidate = ProjectedPlace(place: CheckFixtures.place("1999"), point: CGPoint(x: 500, y: 400))
        var request = CheckFixtures.request([candidate], zoom: .region)
        request.policy = MarkerLayoutPolicy(selectionStyle: .card)
        request.reservations = [MarkerReservation(id: "neighbor", rect: CGRect(x: 525, y: 380, width: 20, height: 40))]
        let result = try await engine.arrange(request)
        try require(result.first?.style == .dot, "Crowded selected marker did not use the dot fallback")
    }
}

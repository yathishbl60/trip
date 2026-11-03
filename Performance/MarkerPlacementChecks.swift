import Foundation
import CoreGraphics

enum MarkerPlacementChecks {
    static func run(_ engine: MarkerLayoutEngine) async throws {
        try await zoomTreatments(engine)
        try await movingPromotions(engine)
        try await movingEntries(engine)
        try await customFallback(engine)
        try await shrinkingClearance(engine)
        try await compactFallback(engine)
        print("PASS: zoom treatments, settled promotions, custom downgrades, and progressive collision fallback")
    }

    private static func zoomTreatments(_ engine: MarkerLayoutEngine) async throws {
        let expected: [MarkerStyle] = [.dot, .thumbnail, .card]
        try require(ZoomLevel.allCases.count == 3 && MarkerStyle.allCases.count == 3, "Expected exactly three appearances")
        for (zoom, style) in zip(ZoomLevel.allCases, expected) {
            let result = try await engine.arrange(request(zoom))
            try require(result.first?.style == style, "Uncrowded annotation has the wrong zoom treatment")
        }
    }

    private static func movingPromotions(_ engine: MarkerLayoutEngine) async throws {
        for zoom in [ZoomLevel.district, .street] {
            let input = request(zoom, settled: false, previous: .dot)
            let moving = try await engine.arrange(input)
            try require(moving.first?.style == .dot, "Zoom boundary promoted a marker during a pinch")
            let settled = try await engine.arrange(request(zoom, previous: .dot))
            try require(settled.first?.style == zoom.styles.first, "Settled zoom did not promote the marker")
        }
    }

    private static func movingEntries(_ engine: MarkerLayoutEngine) async throws {
        let input = request(.street, settled: false)
        let moving = try await engine.arrange(input)
        try require(moving.first?.style == .dot, "New annotation appeared as a card during camera movement")
        let settled = try await engine.arrange(request(.street, previous: .dot))
        try require(settled.first?.style == .card, "Settled entry did not reveal its details")
    }

    private static func customFallback(_ engine: MarkerLayoutEngine) async throws {
        var input = request(.street, settled: false, previous: .thumbnail)
        input.policy = MarkerLayoutPolicy(appearances: [.street: [.card]])
        let result = try await engine.arrange(input)
        try require(result.first?.style == .dot, "Missing old treatment bypassed the gesture promotion ceiling")
    }

    private static func shrinkingClearance(_ engine: MarkerLayoutEngine) async throws {
        var input = request(.region)
        input.previous = ["marker": .card]
        input.reservations = [MarkerReservation(id: "neighbor", rect: CGRect(x: 520, y: 390, width: 40, height: 20))]
        let result = try await engine.arrange(input)
        try require(result.first?.style == .dot, "Shrinking marker was hidden by promotion-only clearance")
    }

    private static func compactFallback(_ engine: MarkerLayoutEngine) async throws {
        var input = request(.street)
        input.reservations = [MarkerReservation(id: "neighbor", rect: CGRect(x: 600, y: 380, width: 20, height: 40))]
        let result = try await engine.arrange(input)
        try require(result.first?.style == .thumbnail, "Crowded detailed view did not fall back to a compact image")
    }

    private static func request(_ zoom: ZoomLevel, settled: Bool = true, previous: MarkerStyle? = nil) -> LayoutRequest {
        let place = ProjectedPlace(place: CheckFixtures.place("marker"), point: CGPoint(x: 500, y: 400))
        var input = CheckFixtures.request([place], zoom: zoom, frame: settled ? 0 : 1)
        if let previous { input.previous = ["marker": previous] }
        return input
    }
}

import Foundation
import CoreGraphics

enum LayoutEdgeChecks {
    static func run(_ engine: MarkerLayoutEngine) async throws {
        var points = CheckFixtures.candidates(0)
        points += Array(repeating: points[0], count: 1_000)
        points += [ProjectedPlace(place: CheckFixtures.place("invalid"), point: CGPoint(x: Double.nan, y: Double.infinity))]
        let request = CheckFixtures.request(points, zoom: .street)
        let result = try await engine.arrange(request)
        try require(result.contains { $0.place.id == "1999" }, "Selected candidate lost beyond cutoff")
        try require(Set(result.map { $0.place.id }).count == result.count, "Duplicate input produced duplicate output")
        try await invalidBounds(engine)
        try await cancellation(engine)
        try await reservation(engine)
        try await candidateBudget(engine)
        try await LayoutVisibilityChecks.run(engine)
    }

    private static func invalidBounds(_ engine: MarkerLayoutEngine) async throws {
        let viewports = [CGRect.zero, CGRect(x: 0, y: 0, width: 20_000, height: 800)]
        for viewport in viewports {
            let request = LayoutRequest(candidates: CheckFixtures.candidates(0), viewport: viewport, exclusions: [], zoom: .district,
                                        scale: 1, selectedID: nil, generation: 0, isSettled: true)
            let result = try await engine.arrange(request)
            try require(result.isEmpty, "Invalid viewport returned markers")
        }
        let invalid = LayoutRequest(candidates: CheckFixtures.candidates(0),
                                    viewport: CGRect(x: 0, y: 0, width: 400, height: 800), exclusions: [],
                                    zoom: .district, scale: .nan, selectedID: nil, generation: 0, isSettled: true)
        let result = try await engine.arrange(invalid)
        try require(result.isEmpty, "Invalid scale returned markers")
    }

    private static func cancellation(_ engine: MarkerLayoutEngine) async throws {
        let input = CheckFixtures.request(CheckFixtures.candidates(0), zoom: .street)
        let task = Task {
            await Task.yield()
            return try await engine.arrange(input)
        }
        task.cancel()
        do {
            _ = try await task.value
            throw CheckFailure(description: "Cancelled layout was accepted")
        } catch is CancellationError { }
        let first = try await engine.arrange(input)
        let second = try await engine.arrange(input)
        try require(first.map { $0.place.id } == second.map { $0.place.id }, "Layout order is not deterministic")
        try require(first.map(\.style) == second.map(\.style), "Marker treatments are not deterministic")
    }

    private static func reservation(_ engine: MarkerLayoutEngine) async throws {
        let candidate = ProjectedPlace(place: CheckFixtures.place("owner"), point: CGPoint(x: 500, y: 400))
        var request = CheckFixtures.request([candidate], zoom: .street)
        let rect = CGRect(x: 300, y: 200, width: 400, height: 400)
        request.reservations = [MarkerReservation(id: "retiring", rect: rect)]
        let blocked = try await engine.arrange(request)
        try require(blocked.isEmpty, "Retiring annotation's footprint was reused")
        request.reservations = [MarkerReservation(id: "owner", rect: rect)]
        let own = try await engine.arrange(request)
        try require(own.count == 1, "Annotation blocked its own morph")
    }

    private static func candidateBudget(_ engine: MarkerLayoutEngine) async throws {
        var points = CheckFixtures.candidates(0)
        points += Array(repeating: points[0], count: 1_000)
        var request = CheckFixtures.request(points, zoom: .street)
        request.policy = MarkerLayoutPolicy(markerLimit: 10, candidateLimit: 40)
        let bounded = try await engine.rank(request)
        request.policy = MarkerLayoutPolicy(markerLimit: 10, candidateLimit: 25_000)
        let complete = try await engine.rank(request)
        try require(bounded.count == 40, "Duplicates consumed the unique candidate budget")
        try require(bounded.map { $0.place.id } == complete.prefix(40).map { $0.place.id }, "Candidate cap changed priority order")
        try require(bounded.first?.place.id == request.selectedID, "Candidate cap discarded the selected place")
    }
}

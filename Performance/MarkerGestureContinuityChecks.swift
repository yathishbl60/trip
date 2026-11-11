import Foundation
import CoreGraphics

@MainActor enum MarkerGestureContinuityChecks {
    static func run(_ engine: MarkerLayoutEngine) async throws {
        let model = LayoutModel()
        defer { model.stop() }
        let initial = MarkerReservationFixtures.candidates(separation: 210)
        let placements = try await engine.arrange(MarkerReservationFixtures.request(initial, zoom: .street, settled: true))
        try require(placements.map(\.style) == [.card, .card], "Gesture fixture did not start with two separate cards")
        model.apply(placements, scale: 1, reduceMotion: false)
        model.markers.forEach { $0.appear() }
        try await compressAndPan(model, engine: engine)
        try await settleAndConverge(model, engine: engine)
    }

    private static func compressAndPan(_ model: LayoutModel, engine: MarkerLayoutEngine) async throws {
        for (index, separation) in [140.0, 100, 55, 100, 100, 100].enumerated() {
            let points = MarkerReservationFixtures.candidates(separation: separation, offset: CGFloat(index * 8))
            let placements = try await engine.arrange(request(model, points: points, zoom: .district))
            try require(placements.map { $0.place.id } == ["a", "b"] && placements.map(\.style) == [.thumbnail, .thumbnail],
                        "Zoom-out or pan made non-overlapping existing thumbnails disappear or change variant")
            model.apply(placements, scale: 1, reduceMotion: false)
            try require(model.markers.allSatisfy(\.hasAppeared), "An uninterrupted gesture restarted native appearance")
        }
    }

    private static func settleAndConverge(_ model: LayoutModel, engine: MarkerLayoutEngine) async throws {
        let points = MarkerReservationFixtures.candidates(separation: 210)
        let moving = try await engine.arrange(request(model, points: points, zoom: .street))
        try require(moving.map(\.style) == [.thumbnail, .thumbnail], "Reverse zoom promoted artwork before settling")
        let settled = try await engine.arrange(request(model, points: points, zoom: .street, settled: true))
        try require(settled.map(\.style) == [.card, .card], "Settled space did not restore detailed markers")
        model.apply(settled, scale: 1, reduceMotion: false)
        model.markers.forEach { $0.clearReservation() }
        for _ in 0..<3 {
            let repeated = try await engine.arrange(request(model, points: points, zoom: .street, settled: true))
            try require(repeated.map { $0.place.id } == ["a", "b"] && repeated.map(\.style) == [.card, .card],
                        "Settled refinement failed to converge on the same marker identities and variants")
            model.apply(repeated, scale: 1, reduceMotion: false)
        }
    }

    private static func request(_ model: LayoutModel, points: [ProjectedPlace], zoom: ZoomLevel,
                                settled: Bool = false) -> LayoutRequest {
        let positions = Dictionary(uniqueKeysWithValues: points.map { ($0.place.id, $0.point) })
        let reservations = model.markers.compactMap { marker -> MarkerReservation? in
            guard marker.reservationUntil != nil, let point = positions[marker.id] else { return nil }
            // Keep the captured morph envelope active without relying on a wall-clock sleep.
            marker.reservationUntil = .now.advanced(by: .seconds(60))
            return marker.reservation(at: point)
        }
        return MarkerReservationFixtures.request(points, zoom: zoom, previous: model.history,
                                                  reservations: reservations, settled: settled)
    }
}

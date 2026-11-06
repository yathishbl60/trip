import CoreGraphics

enum LayoutObstructionChecks {
    static func run(_ engine: MarkerLayoutEngine) async throws {
        let invalid = [CGRect.null, .infinite, CGRect(x: CGFloat.nan, y: 0, width: 100, height: 100),
                       CGRect(x: 0, y: 0, width: CGFloat.infinity, height: 100)]
        for rect in invalid {
            let exclusion = try await engine.arrange(request(exclusions: [rect]))
            try require(exclusion.count == 1, "Invalid exclusion concealed the map")
            let reservation = try await engine.arrange(request(reservations: [MarkerReservation(id: "retired", rect: rect)]))
            try require(reservation.count == 1, "Invalid reservation concealed the map")
        }
        try await finiteCover(engine)
        try await outsideViewport(engine)
        print("PASS: invalid obstructions are ignored while finite covering and owner reservations remain authoritative")
    }

    private static func finiteCover(_ engine: MarkerLayoutEngine) async throws {
        let cover = CGRect(x: -1_000, y: -1_000, width: 4_000, height: 4_000)
        let exclusion = try await engine.arrange(request(exclusions: [cover]))
        try require(exclusion.isEmpty, "Large finite exclusion failed to cover the viewport")
        let reservation = try await engine.arrange(request(reservations: [MarkerReservation(id: "retired", rect: cover)]))
        try require(reservation.isEmpty, "Large finite reservation lost its occupied area")
        let own = try await engine.arrange(request(reservations: [MarkerReservation(id: "marker", rect: cover)]))
        try require(own.count == 1, "Marker could not ignore its own finite reservation")
    }

    private static func outsideViewport(_ engine: MarkerLayoutEngine) async throws {
        let outside = CGRect(x: -500, y: -500, width: 100, height: 100)
        let result = try await engine.arrange(request(exclusions: [outside],
                                                     reservations: [MarkerReservation(id: "retired", rect: outside)]))
        try require(result.count == 1, "Offscreen obstruction blocked the visible map")
    }

    private static func request(exclusions: [CGRect] = [], reservations: [MarkerReservation] = []) -> LayoutRequest {
        let candidate = ProjectedPlace(place: CheckFixtures.place("marker"), point: CGPoint(x: 200, y: 400))
        return LayoutRequest(candidates: [candidate], viewport: CGRect(x: 0, y: 0, width: 400, height: 800),
                             exclusions: exclusions, zoom: .street, scale: 1, selectedID: "marker", generation: 0,
                             isSettled: true, reservations: reservations)
    }
}

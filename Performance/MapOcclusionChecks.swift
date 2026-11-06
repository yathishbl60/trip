import CoreGraphics

@MainActor enum MapOcclusionChecks {
    private static let frame = CGRect(x: 100, y: 200, width: 400, height: 800)

    static func run() async throws {
        try safeEdges()
        try floatingSheet()
        try absentGeometry()
        try await noticeHitBounds()
    }

    private static func safeEdges() throws {
        let content = CGRect(x: 100, y: 244, width: 400, height: 722)
        let exclusions = MapViewportOcclusion.exclusions(mapFrame: frame, contentFrame: content, overlays: [])
        try require(exclusions == [CGRect(x: 0, y: 0, width: 400, height: 44),
                                   CGRect(x: 0, y: 766, width: 400, height: 34)],
                    "Safe-area exclusions changed their local geometry")
        let outside = CGRect(x: 1_000, y: 200, width: 400, height: 800)
        try require(MapViewportOcclusion.exclusions(mapFrame: frame, contentFrame: outside, overlays: []).isEmpty,
                    "Unpaired window-move geometry hid every annotation")
    }

    private static func floatingSheet() throws {
        let floating = CGRect(x: 360, y: 500, width: 260, height: 300)
        let sheet = MapViewportPolicy.sheetExclusion(floating)
        let exclusions = MapViewportOcclusion.exclusions(mapFrame: frame, contentFrame: frame, overlays: [sheet])
        try require(exclusions == [CGRect(x: 252, y: 280, width: 148, height: 340)],
                    "Floating sheet clearance was not clipped into map coordinates")
        let outside = CGRect(x: 800, y: 800, width: 100, height: 100)
        try require(MapViewportOcclusion.exclusions(mapFrame: frame, contentFrame: frame, overlays: [outside]).isEmpty,
                    "An unrelated off-map overlay excluded annotations")
    }

    private static func absentGeometry() throws {
        let invalid: [CGRect] = [.zero, .null, .infinite, CGRect(x: CGFloat.nan, y: 0, width: 100, height: 100),
                                 CGRect(x: 0, y: 0, width: 0, height: 100)]
        for rectangle in invalid {
            try require(MapViewportPolicy.sheetExclusion(rectangle).isNull,
                        "Missing sheet geometry acquired phantom clearance")
            try require(MapViewportOcclusion.exclusions(mapFrame: frame, contentFrame: frame, overlays: [rectangle]).isEmpty,
                        "Invalid overlay became a collision obstacle")
            try require(MapViewportOcclusion.exclusions(mapFrame: rectangle, contentFrame: frame, overlays: []).isEmpty,
                        "Invalid map geometry produced exclusions")
            try require(MapViewportOcclusion.exclusions(mapFrame: frame, contentFrame: rectangle, overlays: []).isEmpty,
                        "Missing content geometry hid every annotation")
        }
    }

    private static func noticeHitBounds() async throws {
        let notice = CGRect(x: 200, y: 900, width: 150, height: 44)
        let height = MarkerStyle.dot.hitSize(scale: 1.5).height
        let candidate = ProjectedPlace(place: CheckFixtures.place("notice-edge"), point: CGPoint(x: 200, y: 700 - height / 2 + 1))
        let engine = MarkerLayoutEngine()
        let covered = try await engine.arrange(request(for: candidate, overlays: [notice], generation: 0))
        try require(covered.isEmpty, "Annotation hit bounds overlapped the measured notice")
        let restored = try await engine.arrange(request(for: candidate, overlays: [.zero], generation: 1))
        try require(restored.map { $0.place.id } == [candidate.place.id], "Disappearing notice retained a stale exclusion")
    }

    private static func request(for candidate: ProjectedPlace, overlays: [CGRect], generation: Int) -> LayoutRequest {
        let exclusions = MapViewportOcclusion.exclusions(mapFrame: frame, contentFrame: frame, overlays: overlays)
        return LayoutRequest(candidates: [candidate], viewport: CGRect(origin: .zero, size: frame.size),
                             exclusions: exclusions, zoom: .region, scale: 1.5, selectedID: nil,
                             generation: generation, isSettled: true)
    }
}

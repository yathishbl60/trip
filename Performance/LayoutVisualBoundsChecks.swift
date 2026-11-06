import CoreGraphics

enum LayoutVisualBoundsChecks {
    static func run(_ engine: MarkerLayoutEngine) async throws {
        for scale in [CGFloat(1), 1.5] {
            for zoom in ZoomLevel.allCases {
                for edge in 0..<4 {
                    try await edgeVisibility(engine, zoom: zoom, scale: scale, edge: edge)
                }
            }
            try await selectedFallback(engine, scale: scale)
        }
        print("PASS: visible artwork, not touch padding, determines edge eligibility at every zoom and scale")
    }

    private static func edgeVisibility(_ engine: MarkerLayoutEngine, zoom: ZoomLevel,
                                       scale: CGFloat, edge: Int) async throws {
        for overlap in [CGFloat(-0.25), 0] {
            let outside = request(zoom: zoom, scale: scale, edge: edge, overlap: overlap)
            let hidden = try await engine.arrange(outside)
            try require(hidden.first?.place.id == "visible", "Invisible artwork consumed the visible marker budget")
        }
        let inside = request(zoom: zoom, scale: scale, edge: edge, overlap: 0.25)
        let visible = try await engine.arrange(inside)
        try require(visible.first?.place.id == "edge", "Partially visible artwork was discarded at an edge")
        try require(visible.first?.style == zoom.styles.first, "Edge overlap changed the zoom appearance")
    }

    private static func selectedFallback(_ engine: MarkerLayoutEngine, scale: CGFloat) async throws {
        let place = candidate("edge", point: CGPoint(x: 10, y: 400), importance: 2)
        let input = LayoutRequest(candidates: [place], viewport: CGRect(x: 0, y: 0, width: 400, height: 800),
                                  exclusions: [], zoom: .street, scale: scale, selectedID: "edge", generation: 0,
                                  isSettled: true)
        let result = try await engine.arrange(input)
        try require(result.first?.style == .thumbnail, "Selected edge label must retain its readable compact fallback")
    }

    private static func request(zoom: ZoomLevel, scale: CGFloat, edge: Int, overlap: CGFloat) -> LayoutRequest {
        let size = zoom.styles[0].size
        let point = edgePoint(edge, width: size.width * scale, height: size.height * scale, overlap: overlap)
        let places = [candidate("edge", point: point, importance: 2),
                      candidate("visible", point: CGPoint(x: 200, y: 400), importance: 0.8)]
        return LayoutRequest(candidates: places, viewport: CGRect(x: 0, y: 0, width: 400, height: 800),
                             exclusions: [], zoom: zoom, scale: scale, selectedID: nil, generation: 0,
                             isSettled: true, policy: MarkerLayoutPolicy(markerLimit: 1, candidateLimit: 1))
    }

    private static func edgePoint(_ edge: Int, width: CGFloat, height: CGFloat, overlap: CGFloat) -> CGPoint {
        switch edge {
        case 0: CGPoint(x: -width / 2 + overlap, y: 400)
        case 1: CGPoint(x: 400 + width / 2 - overlap, y: 400)
        case 2: CGPoint(x: 200, y: -height / 2 + overlap)
        default: CGPoint(x: 200, y: 800 + height / 2 - overlap)
        }
    }

    private static func candidate(_ id: String, point: CGPoint, importance: Double) -> ProjectedPlace {
        let place = Place(id: id, name: id, coordinate: .bangkok, category: .hotel,
                          importance: importance, rating: nil, reviews: nil)
        return ProjectedPlace(place: place, point: point)
    }
}

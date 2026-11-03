import Foundation
import CoreGraphics

enum LayoutChecks {
    static func run() async throws {
        let engine = MarkerLayoutEngine()
        for zoom in ZoomLevel.allCases {
            var history: [String: MarkerStyle] = [:]
            for frame in 0..<100 {
                let points = CheckFixtures.candidates(frame)
                var request = CheckFixtures.request(points, zoom: zoom, frame: frame)
                request.previous = history
                let result = try await engine.arrange(request)
                try validate(result, request, points)
                history = Dictionary(uniqueKeysWithValues: result.map { ($0.place.id, $0.style) })
            }
        }
        try await LayoutEdgeChecks.run(engine)
        try await AnnotationDesignChecks.run()
        try await MarkerPlacementChecks.run(engine)
    }

    private static func validate(_ result: [MarkerPlacement], _ request: LayoutRequest,
                                 _ points: [ProjectedPlace]) throws {
        try require(result.count <= request.policy.markerLimit, "Marker limit exceeded")
        try require(Set(result.map { $0.place.id }).count == result.count, "Duplicate annotation identity")
        let coordinates = Dictionary(uniqueKeysWithValues: points.map { ($0.place.id, $0.point) })
        var rectangles: [CGRect] = request.exclusions
        for marker in result {
            let rect = MarkerGeometry(style: marker.style, scale: request.scale).bounds(at: coordinates[marker.place.id]!)
            try require(!rectangles.contains { $0.intersects(rect) }, "Overlapping footprint at \(request.zoom), \(marker.place.id)")
            rectangles.append(rect)
            if !request.isSettled, let previous = request.previous[marker.place.id] {
                try require(marker.style.rawValue <= previous.rawValue, "Promoted marker during same-level movement")
            }
        }
    }
}

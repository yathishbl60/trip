import Foundation
import CoreGraphics

@MainActor final class LayoutBenchmarks {
    private let engine = MarkerLayoutEngine()
    private let candidates = BenchmarkFixtures.projected()
    private var history: [String: MarkerStyle] = [:]

    func run() async throws -> [BenchmarkMetric] {
        var results: [BenchmarkMetric] = []
        for zoom in ZoomLevel.allCases { results.append(try await measure(zoom)) }
        return results
    }

    private func measure(_ zoom: ZoomLevel) async throws -> BenchmarkMetric {
        var samples: [Double] = []
        var checksum = 0
        for frame in 0..<220 {
            let request = request(zoom, frame: frame)
            let start = ContinuousClock.now
            let placements = try await engine.arrange(request)
            let elapsed = BenchmarkMetric.elapsed(since: start)
            checksum += placements.count
            history = Dictionary(uniqueKeysWithValues: placements.map { ($0.place.id, $0.style) })
            if frame >= 20 { samples.append(elapsed) }
        }
        return BenchmarkMetric(name: "layout/\(zoom.title)", samples: samples, warmups: 20, checksum: checksum)
    }

    private func request(_ zoom: ZoomLevel, frame: Int) -> LayoutRequest {
        LayoutRequest(candidates: candidates, viewport: CGRect(x: 0, y: 0, width: 1_600, height: 1_200),
                      exclusions: [], zoom: zoom, scale: 1.5, selectedID: nil, generation: frame, isSettled: true,
                      previous: history)
    }
}

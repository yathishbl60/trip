import Foundation
import MapKit

enum GeographicBenchmarks {
    static func run() throws -> [BenchmarkMetric] {
        var results: [BenchmarkMetric] = []
        for count in [2_000, 50_000] {
            for extent in [0.4, 6.0] { results += try measure(count: count, extent: extent) }
        }
        return results
    }

    private static func measure(count: Int, extent: Double) throws -> [BenchmarkMetric] {
        let places = BenchmarkFixtures.places(count, extent: extent)
        let candidates = places.map(MapCandidate.init)
        let index = GeographicIndex(places)
        let bounds = BenchmarkFixtures.regions()
        let name = "lookup/\(count)/\(extent)deg"
        let scan = time("\(name)/scan", bounds) { rect in candidates.filter { $0.isNear(rect) }.count }
        let indexed = time("\(name)/index", bounds) { index.query($0, categories: []).count }
        try require(scan.checksum == indexed.checksum, "Benchmark lookup results differ")
        return [scan, indexed]
    }

    private static func time(_ name: String, _ bounds: [MKMapRect], operation: (MKMapRect) -> Int) -> BenchmarkMetric {
        var samples: [Double] = []
        var checksum = 0
        for pass in 0..<12 {
            for rect in bounds {
                let start = ContinuousClock.now
                checksum += operation(rect)
                let elapsed = BenchmarkMetric.elapsed(since: start)
                if pass >= 2 { samples.append(elapsed) }
            }
        }
        return BenchmarkMetric(name: name, samples: samples, warmups: bounds.count * 2, checksum: checksum)
    }
}

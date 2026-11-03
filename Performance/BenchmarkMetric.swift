import Foundation

nonisolated struct BenchmarkMetric: Codable {
    let name: String
    let sampleCount: Int
    let warmupCount: Int
    let medianMicroseconds: Double
    let p95Microseconds: Double
    let checksum: Int

    init(name: String, samples: [Double], warmups: Int, checksum: Int) {
        precondition(!samples.isEmpty)
        let sorted = samples.sorted()
        self.name = name
        sampleCount = sorted.count
        warmupCount = warmups
        medianMicroseconds = sorted[sorted.count / 2]
        p95Microseconds = sorted[min(sorted.count - 1, sorted.count * 95 / 100)]
        self.checksum = checksum
    }

    static func elapsed(since start: ContinuousClock.Instant) -> Double {
        let duration = start.duration(to: .now).components
        return Double(duration.seconds) * 1e6 + Double(duration.attoseconds) / 1e12
    }

    func display() {
        let style = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(3))
        print("\(name): median \(medianMicroseconds.formatted(style)) µs; p95 \(p95Microseconds.formatted(style)) µs")
    }
}

nonisolated struct BenchmarkReport: Encodable {
    let schemaVersion = 1
    let workloadVersion = 2
    let checksPassed: Bool
    let metrics: [BenchmarkMetric]
}

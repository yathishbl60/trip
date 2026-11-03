import Foundation

@MainActor final class SchedulerChecks {
    private let scheduler = LayoutScheduler()
    private var delivered: [Int] = []

    func run() async throws {
        let points = CheckFixtures.candidates(0)
        for generation in 0..<80 {
            scheduler.submit(CheckFixtures.request(points, zoom: .street, frame: generation)) { [self] request, _ in
                delivered.append(request.generation)
            }
        }
        try await waitForDelivery()
        try require(delivered == [79], "Scheduler published superseded requests: \(delivered)")
        delivered.removeAll()
        scheduler.submit(CheckFixtures.request(points, zoom: .district, frame: 80)) { [self] request, _ in
            delivered.append(request.generation)
        }
        scheduler.cancel()
        try await restart(points)
    }

    private func restart(_ points: [ProjectedPlace]) async throws {
        scheduler.submit(CheckFixtures.request(points, zoom: .district, frame: 81)) { [self] request, _ in
            delivered.append(request.generation)
        }
        try await waitForDelivery()
        try require(delivered == [81], "Cancelled work delivered or restart failed: \(delivered)")
        scheduler.cancel()
    }

    private func waitForDelivery() async throws {
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        while delivered.isEmpty && .now < deadline { try await Task.sleep(for: .milliseconds(1)) }
        try require(!delivered.isEmpty, "Layout scheduler timed out")
    }
}

import Foundation
import TripDomain

actor NavigationTestStore: TripStoring {
    private var continuation: CheckedContinuation<[TripPlan], Never>?
    private var started = false
    private var startedWaiters: [CheckedContinuation<Void, Never>] = []

    func load() async throws -> [TripPlan] {
        started = true
        startedWaiters.forEach { $0.resume() }
        startedWaiters = []
        return await withCheckedContinuation { continuation = $0 }
    }

    func waitForLoad() async {
        if started { return }
        await withCheckedContinuation { startedWaiters.append($0) }
    }

    func finish(_ plans: [TripPlan]) {
        continuation?.resume(returning: plans)
        continuation = nil
    }

    func save(_ trips: [TripPlan], revision: Int, changedIDs: Set<UUID>?) async throws {}
}

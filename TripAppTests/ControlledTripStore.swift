import Foundation
import TripDomain

actor ControlledTripStore: TripStoring {
    private struct Save {
        let plans: [TripPlan]
        let continuation: CheckedContinuation<Void, Error>
    }
    private var plans: [TripPlan]
    private var savedRevision = -1
    private var saves: [Int: Save] = [:]
    private var waiters: [Int: [CheckedContinuation<Void, Never>]] = [:]
    private enum Failure: Error { case save }

    init(_ plans: [TripPlan]) { self.plans = plans }
    func load() async throws -> [TripPlan] { plans }

    func save(_ plans: [TripPlan], revision: Int, changedIDs: Set<UUID>?) async throws {
        try await withCheckedThrowingContinuation { continuation in
            saves[revision] = Save(plans: plans, continuation: continuation)
            waiters.removeValue(forKey: revision)?.forEach { $0.resume() }
        }
    }

    func waitForSave(_ revision: Int) async {
        if saves[revision] != nil { return }
        await withCheckedContinuation { waiters[revision, default: []].append($0) }
    }

    func finish(_ revision: Int, failing: Bool = false) {
        guard let save = saves.removeValue(forKey: revision) else { return }
        if failing { save.continuation.resume(throwing: Failure.save); return }
        if revision >= savedRevision {
            plans = save.plans
            savedRevision = revision
        }
        save.continuation.resume()
    }
}

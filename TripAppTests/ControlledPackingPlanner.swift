import Foundation
import TripDomain

/// Intentionally completes canceled calls so the model must reject their results.
actor ControlledPackingPlanner: TripPackingPlanning {
    private var requests: [String: CheckedContinuation<[String], Never>] = [:]
    private var waiters: [String: [CheckedContinuation<Void, Never>]] = [:]

    func suggestions(for context: TripPackingContext, preferences: String) async throws -> [String] {
        await withCheckedContinuation { continuation in
            requests[preferences] = continuation
            waiters.removeValue(forKey: preferences)?.forEach { $0.resume() }
        }
    }

    func waitForRequest(_ preferences: String) async {
        if requests[preferences] != nil { return }
        await withCheckedContinuation { waiters[preferences, default: []].append($0) }
    }

    func finish(_ preferences: String, titles: [String]) {
        requests.removeValue(forKey: preferences)?.resume(returning: titles)
    }
}

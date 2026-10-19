#if !TRIP_STANDALONE
import TripDomain
#endif
import Foundation

/// Successful coverage and a short failure cooldown have separate lifetimes.
public nonisolated struct PlaceSearchHistory: Sendable {
    private var completed: Attempt?
    private var failed: Attempt?

    public init() {}

    public func needsSearch(_ request: PlaceSearchRequest, policy: MapDataPolicy,
                            at now: ContinuousClock.Instant = .now) -> Bool {
        if let failed, failed.request.covers(request) {
            return failed.date.duration(to: now) >= .seconds(2)
        }
        guard let completed, completed.request.covers(request) else { return true }
        return completed.date.duration(to: now) >= policy.cacheLifetime
    }

    public mutating func complete(_ request: PlaceSearchRequest, at now: ContinuousClock.Instant = .now) {
        completed = Attempt(request: request, date: now)
        failed = nil
    }

    public mutating func fail(_ request: PlaceSearchRequest, at now: ContinuousClock.Instant = .now) {
        failed = Attempt(request: request, date: now)
    }

    private struct Attempt: Sendable {
        let request: PlaceSearchRequest
        let date: ContinuousClock.Instant
    }
}

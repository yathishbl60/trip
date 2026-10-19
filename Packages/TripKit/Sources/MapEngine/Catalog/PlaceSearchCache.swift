#if !TRIP_STANDALONE
import TripDomain
#endif
import Foundation

/// Bounded coverage reuse; a cache hit never extends the provider response's freshness.
nonisolated struct PlaceSearchCache {
    private var entries: [PlaceSearchRequest: Entry] = [:]
    private var access = 0
    private let policy: MapDataPolicy

    init(policy: MapDataPolicy) { self.policy = policy }

    mutating func response(for request: PlaceSearchRequest,
                           at now: ContinuousClock.Instant = .now) -> PlaceSearchResponse? {
        removeExpired(at: now)
        let key = entries[request] != nil ? request : entries
            .filter { $0.key.covers(request) }
            .max { $0.value.access < $1.value.access }?.key
        guard let key, var entry = entries[key] else { return nil }
        access += 1
        entry.access = access
        entries[key] = entry
        return entry.response
    }

    mutating func store(_ response: PlaceSearchResponse, at now: ContinuousClock.Instant = .now) {
        guard policy.cacheLimit > 0, policy.cacheLifetime > .zero else { return }
        removeExpired(at: now)
        let request = response.request
        if entries[request] == nil, entries.count >= policy.cacheLimit,
           let oldest = entries.min(by: { $0.value.access < $1.value.access })?.key {
            entries.removeValue(forKey: oldest)
        }
        access += 1
        entries[request] = Entry(response: response, access: access)
    }

    private mutating func removeExpired(at now: ContinuousClock.Instant) {
        entries = entries.filter { $0.value.response.fetchedAt.duration(to: now) < policy.cacheLifetime }
    }

    private struct Entry: Sendable {
        let response: PlaceSearchResponse
        var access: Int
    }
}

import Foundation
import TripDomain

nonisolated enum NearbySearchRadius: Double, CaseIterable, Identifiable {
    case close = 500, neighborhood = 1_500, wider = 3_000
    var id: Double { rawValue }
    var title: String {
        Measurement(value: rawValue, unit: UnitLength.meters).formatted(.measurement(width: .abbreviated, usage: .road))
    }
}

nonisolated struct NearbySearchScope: Hashable {
    let category: NearbyPlaceCategory
    let radius: NearbySearchRadius
}

/// One origin owns at most the fifteen category/distance combinations for five minutes.
nonisolated struct NearbySearchCache {
    private var entries: [NearbySearchScope: CachedNearbyPlaces] = [:]

    mutating func store(_ places: [Place], for scope: NearbySearchScope) {
        entries[scope] = CachedNearbyPlaces(places: places, fetched: .now)
    }

    func places(for scope: NearbySearchScope, at now: ContinuousClock.Instant = .now) -> [Place]? {
        guard let entry = entries[scope], entry.fetched.duration(to: now) < .seconds(300) else { return nil }
        return entry.places
    }

    mutating func remove(_ scope: NearbySearchScope) { entries[scope] = nil }

    private struct CachedNearbyPlaces {
        let places: [Place]
        let fetched: ContinuousClock.Instant
    }
}

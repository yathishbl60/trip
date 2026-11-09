import TripLocalization
import Foundation
import MapKit
import Observation
import TripDomain

@MainActor @Observable final class PlaceNearbySearchModel {
    let origin: Place
    private(set) var places: [Place]
    private(set) var isLoading = false
    private(set) var error: String?
    private(set) var retryRevision = 0
    private(set) var category = NearbyPlaceCategory.all
    private(set) var radius = NearbySearchRadius.neighborhood
    @ObservationIgnored private var cache = NearbySearchCache()
    @ObservationIgnored private var generation = 0

    init(origin: Place, results: [Place]? = nil) {
        self.origin = origin
        places = results ?? []
        if let results { cache.store(results, for: scope) }
    }

    var scope: NearbySearchScope { NearbySearchScope(category: category, radius: radius) }

    func load() async {
        if let cached = cache.places(for: scope) { places = cached; isLoading = false; return }
        generation += 1
        let token = generation
        isLoading = true
        error = nil
        defer { if token == generation { isLoading = false } }
        do {
            let scope = scope
            let results = try await fetch(scope)
            guard !Task.isCancelled, token == generation else { return }
            accept(results, radius: scope.radius.rawValue)
            cache.store(places, for: scope)
        } catch {
            guard !Task.isCancelled, token == generation else { return }
            self.error = TripText.couldnTFindNearbyPlacesTryAgain.text
        }
    }

    private func accept(_ results: [Place], radius: Double) {
        var seen: Set<String> = [origin.id]
        places = results.filter {
            $0.coordinate.isValid && seen.insert($0.id).inserted
                && $0.coordinate.distance(to: origin.coordinate) <= radius
        }.sorted {
            $0.coordinate.distance(to: origin.coordinate) < $1.coordinate.distance(to: origin.coordinate)
        }
    }

    func retry() {
        cache.remove(scope)
        retryRevision += 1
    }

    func choose(_ category: NearbyPlaceCategory) {
        guard self.category != category else { return }
        self.category = category
        scopeChanged()
    }

    func choose(_ radius: NearbySearchRadius) {
        guard self.radius != radius else { return }
        self.radius = radius
        scopeChanged()
    }

    private func scopeChanged() {
        generation += 1
        let cached = cache.places(for: scope)
        places = cached ?? []
        error = nil
        isLoading = cached == nil
        retryRevision += 1
    }
}

nonisolated struct PlaceNearbyRequestID: Hashable {
    let revision: Int
    let isActive: Bool
}

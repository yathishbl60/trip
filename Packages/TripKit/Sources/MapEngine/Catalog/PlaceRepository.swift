import TripDomain
import Foundation

public actor PlaceRepository {
    private var cache: PlaceSearchCache
    private var samplePlaces: [Place]?
    private let provider: any PlaceProviding
    private let policy: MapDataPolicy

    public init(provider: any PlaceProviding, policy: MapDataPolicy = .init()) {
        self.provider = provider
        self.policy = policy
        cache = PlaceSearchCache(policy: policy)
    }

    public func merge(_ incoming: [Place], into places: [Place], preserving id: String?) throws -> CatalogSnapshot {
        var collection = PlaceCollection(places, preserving: id, policy: policy)
        return try CatalogSnapshot(collection.merge(incoming))
    }

    public func mergeSearch(_ incoming: [Place], into places: [Place], preserving id: String?) throws -> CatalogSearchUpdate {
        var collection = PlaceCollection(places, preserving: id, policy: policy)
        let catalog = try CatalogSnapshot(collection.merge(incoming))
        return CatalogSearchUpdate(catalog: catalog, matches: CatalogSnapshot(collection.matchingPlaces))
    }

    public func localMatches(_ query: String, in places: [Place]) throws -> CatalogSnapshot {
        try Task.checkCancellation()
        let matches = PlaceSearchQuery(query).places(in: places)
        try Task.checkCancellation()
        return CatalogSnapshot(Array(matches.prefix(100)))
    }

    public func seeds() async throws -> [Place] {
        if let samplePlaces { return samplePlaces }
        let places = try await provider.initialPlaces()
        try Task.checkCancellation()
        samplePlaces = places
        return places
    }

    public func search(_ request: PlaceSearchRequest, refresh: Bool = false) async throws -> [Place] {
        try await response(for: request, refresh: refresh).places
    }

    public func response(for request: PlaceSearchRequest, refresh: Bool = false) async throws -> PlaceSearchResponse {
        try Task.checkCancellation()
        if !refresh, let response = cache.response(for: request) { return response }
        let places = try await provider.search(request)
        try Task.checkCancellation()
        let response = PlaceSearchResponse(places: places, request: request)
        cache.store(response)
        return response
    }
}

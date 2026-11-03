import Foundation
import MapKit

enum SearchCacheChecks {
    static func run() throws {
        try reuse()
        try expiration()
        try retention()
        try disabled()
        print("PASS: bounded search cache reuses coverage, preserves freshness, and retains recently used areas")
    }

    private static func reuse() throws {
        let now = ContinuousClock.now
        let original = request()
        var cache = PlaceSearchCache(policy: .init())
        let response = PlaceSearchResponse(places: [CheckFixtures.place("one")], request: original, fetchedAt: now)
        cache.store(response, at: now)
        let hit = cache.response(for: request(longitude: 100.501), at: now.advanced(by: .seconds(1)))
        try require(hit?.request == original && hit?.fetchedAt == now, "Cache hit altered coverage or freshness")
        try require(hit?.places.map(\.id) == ["one"], "Nearby camera coverage did not reuse results")
        try require(cache.response(for: request(query: "cafe"), at: now) == nil, "Query reused unrelated results")
        try require(cache.response(for: request(categories: [.park]), at: now) == nil,
                    "Category filter reused unrelated results")
        try require(cache.response(for: request(span: 0.03), at: now) == nil, "Zoom detail reused broader results")
        try require(cache.response(for: request(longitude: 100.6), at: now) == nil, "New area reused stale coverage")
    }

    private static func expiration() throws {
        let now = ContinuousClock.now
        var cache = PlaceSearchCache(policy: .init(cacheLifetime: .seconds(10)))
        cache.store(PlaceSearchResponse(places: [], request: request(), fetchedAt: now), at: now)
        try require(cache.response(for: request(), at: now.advanced(by: .seconds(9))) != nil,
                    "Fresh empty response was not cached")
        try require(cache.response(for: request(), at: now.advanced(by: .seconds(10))) == nil,
                    "Cache access extended response lifetime")
    }

    private static func retention() throws {
        let now = ContinuousClock.now
        let first = request(), second = request(longitude: 101), third = request(longitude: 102)
        var cache = PlaceSearchCache(policy: .init(cacheLimit: 2))
        cache.store(PlaceSearchResponse(places: [], request: first, fetchedAt: now), at: now)
        cache.store(PlaceSearchResponse(places: [], request: second, fetchedAt: now), at: now)
        cache.store(PlaceSearchResponse(places: [], request: second, fetchedAt: now), at: now)
        try require(cache.response(for: first, at: now) != nil, "Replacing a key evicted an unrelated area")
        cache.store(PlaceSearchResponse(places: [], request: third, fetchedAt: now), at: now)
        try require(cache.response(for: first, at: now) != nil, "A recently used area was evicted")
        try require(cache.response(for: second, at: now) == nil, "Least recently used area exceeded cache bound")
        try require(cache.response(for: third, at: now) != nil, "Newest area was not retained")
    }

    private static func disabled() throws {
        let now = ContinuousClock.now
        for policy in [MapDataPolicy(cacheLimit: 0), MapDataPolicy(cacheLifetime: .zero)] {
            var cache = PlaceSearchCache(policy: policy)
            cache.store(PlaceSearchResponse(places: [], request: request(), fetchedAt: now), at: now)
            try require(cache.response(for: request(), at: now) == nil, "Disabled cache retained results")
        }
    }

    private static func request(longitude: Double = 100.5, span: Double = 0.06,
                                query: String = "", categories: Set<PlaceCategory> = [.hotel]) -> PlaceSearchRequest {
        let region = MKCoordinateRegion(center: Coordinate(latitude: 13.75, longitude: longitude).location,
                                         span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
        return PlaceSearchRequest(area: SearchArea(region), query: query, categories: categories)
    }
}

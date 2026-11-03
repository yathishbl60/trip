import Foundation
import MapKit

enum SearchHistoryChecks {
    static func run() throws {
        try completion()
        try failure()
        print("PASS: successful search coverage, short failure cooldown, and refresh recovery stay separate")
    }

    private static func completion() throws {
        let now = ContinuousClock.now
        let request = makeRequest()
        let policy = MapDataPolicy(cacheLifetime: .seconds(60))
        var history = PlaceSearchHistory()
        try require(history.needsSearch(request, policy: policy, at: now), "First search was suppressed")
        history.complete(request, at: now)
        try require(!history.needsSearch(request, policy: policy, at: now.advanced(by: .seconds(59))),
                    "Fresh completed coverage was searched again")
        try require(history.needsSearch(request, policy: policy, at: now.advanced(by: .seconds(60))),
                    "Expired completed coverage was treated as fresh")
        try require(history.needsSearch(makeRequest("cafe"), policy: policy, at: now),
                    "Completed coverage suppressed a different query")
        try require(history.needsSearch(request, policy: MapDataPolicy(cacheLifetime: .zero), at: now),
                    "Completed coverage ignored a disabled cache lifetime")
    }

    private static func failure() throws {
        let now = ContinuousClock.now
        let request = makeRequest()
        let policy = MapDataPolicy()
        var history = PlaceSearchHistory()
        history.complete(request, at: now)
        history.fail(request, at: now)
        try require(!history.needsSearch(request, policy: policy, at: now.advanced(by: .seconds(1))),
                    "Repeated camera callbacks bypassed failure cooldown")
        try require(history.needsSearch(request, policy: policy, at: now.advanced(by: .seconds(2))),
                    "Failure was incorrectly cached as a successful search")
        try require(history.needsSearch(makeRequest("cafe"), policy: policy, at: now),
                    "Failure cooldown suppressed a different query")
        history.complete(request, at: now.advanced(by: .seconds(3)))
        try require(!history.needsSearch(request, policy: policy, at: now.advanced(by: .seconds(4))),
                    "Successful retry did not replace failure cooldown")
    }

    private static func makeRequest(_ query: String = "") -> PlaceSearchRequest {
        let region = MKCoordinateRegion(center: Coordinate.bangkok.location,
                                         span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06))
        return PlaceSearchRequest(area: SearchArea(region), query: query, categories: [.hotel])
    }
}

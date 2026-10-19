#if !TRIP_STANDALONE
import TripDomain
#endif
import Foundation

public nonisolated struct PlaceSearchResponse: Sendable {
    public let places: [Place]
    public let request: PlaceSearchRequest
    public let fetchedAt: ContinuousClock.Instant

    public init(places: [Place], request: PlaceSearchRequest, fetchedAt: ContinuousClock.Instant = .now) {
        self.places = places
        self.request = request
        self.fetchedAt = fetchedAt
    }
}

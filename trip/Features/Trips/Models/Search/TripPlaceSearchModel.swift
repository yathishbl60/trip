import TripPlaces
import Observation
import TripDomain
import Foundation

@MainActor @Observable final class TripPlaceSearchModel {
    var places: [Place] = []
    var isSearching = false
    var error: String?
    var resolvedQuery: String?
    @ObservationIgnored var generation = 0
    @ObservationIgnored var operation: (any PlaceSearching)?
    @ObservationIgnored var deadline: Task<Void, Never>?
    @ObservationIgnored let makeOperation: (@MainActor () -> any PlaceSearching)?
    var canSearch: Bool { makeOperation != nil }

    init(places: [Place] = [], query: String? = nil, error: String? = nil, isSearching: Bool = false,
         makeOperation: (@MainActor () -> any PlaceSearching)? = nil) {
        self.places = places
        resolvedQuery = query
        self.error = error
        self.isSearching = isSearching
        self.makeOperation = makeOperation
    }

    func cancel() {
        generation += 1
        deadline?.cancel()
        operation?.cancel()
        operation = nil
        isSearching = false
    }

    func clear() {
        cancel()
        places = []
        error = nil
        resolvedQuery = nil
    }

    func prepare(_ query: String) {
        cancel()
        error = nil
        if query.isEmpty {
            places = []
            resolvedQuery = nil
            return
        }
        if resolvedQuery != query { places = PlaceSearchQuery(query).places(in: places) }
        resolvedQuery = query
        isSearching = canSearch
    }

}

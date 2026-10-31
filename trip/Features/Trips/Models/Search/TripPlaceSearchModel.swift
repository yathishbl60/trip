import Observation
import TripDomain
import Foundation

@MainActor @Observable final class TripPlaceSearchModel {
    var places: [Place] = []
    var isSearching = false
    var error: String?
    var resolvedQuery: String?
    @ObservationIgnored var generation = 0
    @ObservationIgnored var operation: PlaceTextSearch?
    @ObservationIgnored var deadline: Task<Void, Never>?
    let allowsLiveSearch: Bool

    init(places: [Place] = [], query: String? = nil, error: String? = nil, isSearching: Bool = false,
         allowsLiveSearch: Bool = true) {
        self.places = places
        resolvedQuery = query
        self.error = error
        self.isSearching = isSearching
        self.allowsLiveSearch = allowsLiveSearch
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
        isSearching = allowsLiveSearch
    }

}

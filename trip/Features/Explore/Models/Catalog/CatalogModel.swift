import TripPlaces
import TripDomain
import MapEngine
import Observation
import Foundation

@MainActor @Observable final class CatalogModel {
    var places: [Place] = []
    var query = ""
    var isSearchPresented = false
    var isSearching = false
    var status = ""
    var canRetrySearch = false
    let autocomplete = PlaceAutocompleteModel()
    var isSubmittedSearch = false
    @ObservationIgnored var completionSearch: PlaceTextSearch?
    var revision = 0
    @ObservationIgnored var hasLoaded = false
    @ObservationIgnored var canSearch = false
    @ObservationIgnored let repository: PlaceRepository
    @ObservationIgnored let policy: MapDataPolicy
    @ObservationIgnored var searchTask: Task<Void, Never>?
    @ObservationIgnored var searchGeneration = 0
    @ObservationIgnored var pendingSearch: PlaceSearchRequest?
    @ObservationIgnored var history = PlaceSearchHistory()
    var isFetching = false
    @ObservationIgnored var progressTask: Task<Void, Never>?
    @ObservationIgnored var timeoutTask: Task<Void, Never>?
    @ObservationIgnored var index = GeographicIndex()
    @ObservationIgnored var counts: [PlaceCategory: Int] = [:]
    var searchResults: CatalogSnapshot?
    var matchingPlaces: [Place] { searchResults?.places ?? [] }
    var searchText: String { PlaceSearchQuery(query).text }
    var isTextSearch: Bool { !searchText.isEmpty }
    var usesSearchResults: Bool { isTextSearch && isSubmittedSearch }
    var visibleIndex: GeographicIndex { usesSearchResults ? searchResults?.index ?? index : index }
    var visibleCounts: [PlaceCategory: Int] { usesSearchResults ? searchResults?.counts ?? counts : counts }

    init(provider: any PlaceProviding = ApplePlaceProvider(), policy: MapDataPolicy = .init()) {
        repository = PlaceRepository(provider: provider, policy: policy)
        self.policy = policy
    }

    func cancelSearch() {
        searchTask?.cancel()
        searchTask = nil
        searchGeneration += 1
        completionSearch?.cancel()
        completionSearch = nil
        pendingSearch = nil
        endProgress()
    }

    func cancelScheduledSearch() {
        guard !isFetching else { return }
        cancelSearch()
    }

    func setSearchPresented(_ presented: Bool) {
        guard isSearchPresented != presented else { return }
        isSearchPresented = presented
        if !presented {
            autocomplete.cancel()
            if completionSearch != nil { cancelSearch() }
        }
    }

    func merge(_ incoming: [Place]) {
        var collection = PlaceCollection(places, policy: policy)
        if let merged = try? collection.merge(incoming) { replace(with: CatalogSnapshot(merged)) }
    }

    func replace(with snapshot: CatalogSnapshot) {
        guard places != snapshot.places else { return }
        places = snapshot.places
        index = snapshot.index
        counts = snapshot.counts
        revision += 1
    }
}

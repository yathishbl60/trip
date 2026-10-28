import TripLocalization
import TripDomain
import MapEngine
import Foundation

extension CatalogModel {
    func acceptSearch(_ update: CatalogSearchUpdate, query: String) {
        replace(with: update.catalog)
        searchResults = query.isEmpty ? nil : update.matches
        canRetrySearch = false
        status = update.matches.places.isEmpty
            ? (query.isEmpty ? TripText.noPlacesNearby.text : TripText.noMatchesInThisArea.text) : ""
    }

    var searchFailureMessage: String {
        visibleCounts.isEmpty ? TripText.canTLoadPlaces.text
            : TripText.canTRefreshPlaces.text
    }

    func needsSearch(_ request: PlaceSearchRequest) -> Bool {
        if let pendingSearch { return !pendingSearch.covers(request) }
        return history.needsSearch(request, policy: policy)
    }

    func beginProgress(generation: Int) {
        isFetching = true
        status = ""
        canRetrySearch = false
        progressTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(250))
            guard let self, !Task.isCancelled, generation == searchGeneration else { return }
            isSearching = true
        }
        timeoutTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(15))
            guard let self, !Task.isCancelled, generation == searchGeneration else { return }
            if let pendingSearch { history.fail(pendingSearch) }
            cancelSearch()
            status = TripText.searchTimedOut.text
            canRetrySearch = true
        }
    }

    func finishSearch() {
        pendingSearch = nil
        searchTask = nil
        completionSearch = nil
        endProgress()
    }

    func endProgress() {
        progressTask?.cancel()
        timeoutTask?.cancel()
        progressTask = nil
        timeoutTask = nil
        isFetching = false
        isSearching = false
    }
}

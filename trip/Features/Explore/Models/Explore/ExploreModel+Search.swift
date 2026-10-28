import MapEngine
import TripDomain
import Foundation
import SwiftUI

extension ExploreModel {
    func updateSearchQuery(_ query: String) {
        guard catalog.query != query else { return }
        let previous = catalog.searchText
        catalog.query = query
        guard catalog.searchText != previous else { return }
        catalog.cancelSearch()
        catalog.isSubmittedSearch = false
        catalog.history = PlaceSearchHistory()
        refineSearchResults()
        catalog.status = ""
        catalog.canRetrySearch = false
        filterPlaces()
        refreshAutocomplete()
        scheduleSearch()
    }

    func clearSearch() {
        catalog.cancelSearch()
        catalog.autocomplete.cancel()
        catalog.setSearchPresented(false)
        catalog.query = ""
        catalog.searchResults = nil
        catalog.status = ""
        catalog.canRetrySearch = false
        filterPlaces()
        scheduleSearch()
    }

    func searchPresentationChanged(_ presented: Bool) {
        if presented {
            select(nil)
            filters.isPresented = false
            environment.dismissSave()
        }
        catalog.setSearchPresented(presented)
        refreshAutocomplete()
        if presented { scheduleSearch() }
    }

    func scheduleSearch(force: Bool = false) {
        guard isActive, catalog.canSearch, force || !camera.isMoving else { return }
        guard !catalog.isTextSearch || catalog.isSubmittedSearch else { return }
        let request = PlaceSearchRequest(area: SearchArea(camera.region),
            query: catalog.searchText,
            categories: catalog.isTextSearch ? [] : filters.effectiveCategories)
        guard force || catalog.needsSearch(request) else { return }
        catalog.cancelSearch()
        catalog.status = ""
        let generation = catalog.searchGeneration
        catalog.pendingSearch = request
        catalog.searchTask = Task {
            do {
                try await Task.sleep(for: force ? .zero : configuration.data.debounce)
                await showLocalMatches(request.query, generation: generation)
                await search(request, generation: generation, refresh: force)
            } catch { /* Debounce follows the latest camera or search text. */ }
        }
    }

    private func search(_ request: PlaceSearchRequest, generation: Int, refresh: Bool) async {
        guard !Task.isCancelled, generation == catalog.searchGeneration else { return }
        catalog.beginProgress(generation: generation)
        defer { if generation == catalog.searchGeneration { catalog.finishSearch() } }
        do {
            let response = try await catalog.repository.response(for: request, refresh: refresh)
            guard !Task.isCancelled, generation == catalog.searchGeneration else { return }
            let merged = try await catalog.repository.mergeSearch(response.places, into: catalog.places,
                                                                  preserving: selectedPlace?.id)
            guard !Task.isCancelled, generation == catalog.searchGeneration else { return }
            catalog.history.complete(response.request, at: response.fetchedAt)
            catalog.acceptSearch(merged, query: request.query)
            filterPlaces()
        } catch {
            guard !Task.isCancelled, generation == catalog.searchGeneration else { return }
            catalog.history.fail(request)
            catalog.status = catalog.searchFailureMessage
            catalog.canRetrySearch = true
        }
    }

    func chooseSearchResult(_ choice: Place, saving: Bool) {
        guard let place = catalog.matchingPlaces.first(where: { $0.id == choice.id }) else { return }
        catalog.cancelSearch()
        catalog.setSearchPresented(false)
        catalog.merge([place])
        if saving { environment.savePlace?(place); return }
        camera.focus(place.coordinate)
        select(place)
    }
}

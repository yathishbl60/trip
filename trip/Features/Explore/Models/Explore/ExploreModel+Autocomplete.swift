import TripLocalization
import MapEngine
import TripDomain
import MapKit

extension ExploreModel {
    func refreshAutocomplete() {
        guard catalog.isSearchPresented, catalog.isTextSearch, !catalog.isSubmittedSearch else {
            catalog.autocomplete.cancel()
            return
        }
        catalog.autocomplete.update(catalog.searchText, region: camera.region)
    }

    func submitSearch() {
        catalog.isSubmittedSearch = true
        catalog.autocomplete.cancel()
        scheduleSearch(force: true)
    }

    func retryAutocomplete() {
        guard catalog.isSearchPresented, catalog.isTextSearch, !catalog.isSubmittedSearch else { return }
        catalog.cancelSearch()
        catalog.status = ""
        catalog.canRetrySearch = false
        refreshAutocomplete()
    }

    func chooseSuggestion(_ id: String) {
        guard catalog.isSearchPresented, !catalog.isFetching,
              catalog.autocomplete.suggestions.contains(where: { $0.id == id }) else { return }
        catalog.cancelSearch()
        catalog.autocomplete.cancel()
        let generation = catalog.searchGeneration
        let operation = PlaceTextSearch()
        catalog.completionSearch = operation
        catalog.beginProgress(generation: generation)
        catalog.searchTask = Task { await resolveSuggestion(id, operation: operation, generation: generation) }
    }

    private func resolveSuggestion(_ id: String, operation: PlaceTextSearch, generation: Int) async {
        defer { if generation == catalog.searchGeneration { catalog.finishSearch() } }
        do {
            let places = try await catalog.autocomplete.resolve(id, using: operation)
            guard !Task.isCancelled, generation == catalog.searchGeneration else { return }
            let update = try await catalog.repository.mergeSearch(places, into: catalog.places, preserving: selectedPlace?.id)
            guard !Task.isCancelled, generation == catalog.searchGeneration else { return }
            catalog.isSubmittedSearch = true
            catalog.acceptSearch(update, query: catalog.searchText)
            filterPlaces()
            if update.matches.places.count == 1, let place = update.matches.places.first {
                chooseSearchResult(place, saving: false)
            }
        } catch {
            guard !Task.isCancelled, generation == catalog.searchGeneration else { return }
            catalog.status = TripText.couldnTOpenThatSuggestionTryAgain.text
            catalog.canRetrySearch = true
        }
    }
}

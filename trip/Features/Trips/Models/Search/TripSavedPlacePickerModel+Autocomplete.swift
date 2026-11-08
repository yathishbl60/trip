import TripDomain

extension TripSavedPlacePickerModel {
    func searchSuggestions() {
        search.cancel()
        guard search.canSearch else { return }
        autocomplete.update(searchTerm, near: searchOrigin?.coordinate)
    }

    func chooseSuggestion(_ id: String) {
        guard !isSubmittedSearch, let suggestion = autocomplete.suggestions.first(where: { $0.id == id }) else { return }
        cancelSearch()
        query = suggestion.title
        suggestionID = id
        isSubmittedSearch = true
        searchRevision += 1
    }

    func submitSearch() {
        autocomplete.cancel()
        suggestionID = nil
        isSubmittedSearch = true
        searchRevision += 1
    }

    func cancelSearch() {
        search.cancel()
        autocomplete.cancel()
    }
}

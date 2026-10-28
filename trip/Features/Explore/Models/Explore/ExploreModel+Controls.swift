extension ExploreModel {
    var showsMapControls: Bool {
        selectedPlace == nil && !environment.isSavingPlace()
    }

    var canSavePlaces: Bool { configuration.showsTrips && environment.savePlace != nil }

    var showsCategoryControls: Bool {
        configuration.showsFilters && filters.categories.count > 1 && !filters.rows.isEmpty
    }

    var canRetrySearch: Bool { catalog.canRetrySearch && !catalog.isSearching }
}

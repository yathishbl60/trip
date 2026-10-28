import TripDomain
import MapEngine

extension ExploreModel {
    func refineSearchResults() {
        guard catalog.isTextSearch else { catalog.searchResults = nil; return }
        let previous = Array(catalog.matchingPlaces.prefix(100))
        catalog.searchResults = CatalogSnapshot(PlaceSearchQuery(catalog.searchText).places(in: previous))
    }

    func showLocalMatches(_ query: String, generation: Int) async {
        guard !query.isEmpty, catalog.matchingPlaces.isEmpty, !Task.isCancelled else { return }
        let matches = try? await catalog.repository.localMatches(query, in: catalog.places)
        guard let matches, generation == catalog.searchGeneration, !Task.isCancelled else { return }
        catalog.searchResults = matches
        filterPlaces()
    }
}

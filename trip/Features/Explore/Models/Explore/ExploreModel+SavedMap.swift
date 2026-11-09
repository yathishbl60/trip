import MapEngine
import TripDomain

extension ExploreModel {
    var discoveryIndex: GeographicIndex { savedMap.isActive ? savedMap.snapshot.index : catalog.visibleIndex }
    var discoveryCounts: [PlaceCategory: Int] { savedMap.isActive ? savedMap.snapshot.counts : catalog.visibleCounts }
    var searchMatches: [Place] { savedMap.isActive ? savedMap.snapshot.places : catalog.matchingPlaces }
    var discoveryIsSearching: Bool { savedMap.isActive ? savedMap.isLoading : catalog.isSearching }
    var discoveryStatus: String { savedMap.isActive ? "" : catalog.status }

    func chooseSavedScope(_ scope: SavedMapScope) {
        guard savedMap.scope != scope else { return }
        savedMap.choose(scope)
        catalog.cancelSearch()
        catalog.autocomplete.cancel()
        browse.invalidate(clear: true)
        filterPlaces()
        if !savedMap.isActive { refreshAutocomplete(); scheduleSearch() }
    }

    func refreshSavedMap(_ request: SavedMapRequest) async {
        guard request.scope != .all else { return }
        if case .trip(let id) = request.scope, !request.groups.contains(where: { $0.id == id }) {
            chooseSavedScope(.saved)
            return
        }
        guard await savedMap.load(request) else { return }
        if savedMap.isActive { filterPlaces() }
    }
}

import TripDomain

extension ExploreModel {
    func chooseRecent(_ entry: RecentPlaceEntry) {
        guard history.history.entries.contains(where: { $0.id == entry.id }) else { return }
        switch entry {
        case .search(let query):
            updateSearchQuery(query)
            submitSearch()
        case .place(let place):
            history.record(entry)
            catalog.cancelSearch()
            catalog.setSearchPresented(false)
            catalog.merge([place])
            camera.focus(place.coordinate)
            select(place)
        }
    }
}

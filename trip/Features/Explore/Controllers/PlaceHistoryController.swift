import TripDomain

@MainActor struct PlaceHistoryController {
    let model: ExploreModel
    func choose(_ entry: RecentPlaceEntry) { model.chooseRecent(entry) }
    func clear() { model.history.clear() }
    func retry() { model.history.persist() }
    func load() async { await model.history.load() }
}

@MainActor struct PlaceNearbySearchController {
    let model: PlaceNearbySearchModel

    func load() async { await model.load() }
    func retry() { model.retry() }
}

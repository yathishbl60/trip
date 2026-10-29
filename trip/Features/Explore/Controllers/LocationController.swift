@MainActor struct LocationController {
    let model: ExploreModel

    func changed() {
        model.requestProjection()
        model.directionsLocationChanged()
    }
}

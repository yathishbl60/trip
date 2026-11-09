import SwiftUI

@MainActor struct PlaceNearbySearchController {
    let model: PlaceNearbySearchModel

    var category: Binding<NearbyPlaceCategory> {
        Binding(get: { model.category }, set: { model.choose($0) })
    }

    func load() async { await model.load() }
    func retry() { model.retry() }
}

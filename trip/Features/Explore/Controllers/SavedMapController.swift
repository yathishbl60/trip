import SwiftUI
import TripDomain
import TripLocalization

@MainActor struct SavedMapController {
    let model: ExploreModel

    var scope: Binding<SavedMapScope> {
        Binding(get: { model.savedMap.scope }, set: model.chooseSavedScope)
    }

    var request: SavedMapRequest {
        SavedMapRequest(groups: model.environment.savedCatalog(), scope: model.savedMap.scope,
                        query: model.catalog.searchText)
    }

    var title: String {
        if case .trip(let id) = model.savedMap.scope {
            return model.environment.savedCatalog().first { $0.id == id }?.title ?? TripText.savedPlaces.text
        }
        return model.savedMap.isActive ? TripText.savedPlaces.text : TripText.allPlaces.text
    }

    func refresh(_ request: SavedMapRequest) async { await model.refreshSavedMap(request) }
}

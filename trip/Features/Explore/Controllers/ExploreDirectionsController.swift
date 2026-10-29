import SwiftUI
import TripDomain
import MapEngine

@MainActor struct ExploreDirectionsController {
    let model: ExploreModel

    func begin(_ place: Place) { model.showDirections(to: place) }

    func updated() {
        model.requestProjection()
        model.scheduleDirectionsFit()
    }
}

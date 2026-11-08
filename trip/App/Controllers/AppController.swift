import SwiftUI
import TripDomain
import Foundation

@MainActor struct AppController {
    let model: AppModel

    var tab: Binding<AppTab> {
        Binding(get: { model.navigation.tab }, set: model.selectTab)
    }

    var hasNavigationNotice: Binding<Bool> {
        Binding(get: { model.navigation.notice != nil },
                set: { if !$0 { model.navigation.notice = nil } })
    }

    var mapSaveDestination: Binding<TripPlaceSaveSession?> {
        let destination = TripController(model: model.trips).placeSaveDestination
        return Binding(get: { model.explore.selectedPlace == nil ? destination.wrappedValue : nil },
                       set: { destination.wrappedValue = $0 })
    }

    func showExplore() { model.showExplore() }
    func start(_ phase: ScenePhase, tab: String, tripID: String, initialTripID: UUID?) async {
        if phase == .active { await model.restore(tab: tab, tripID: tripID, initialTripID: initialTripID) }
        guard !Task.isCancelled else { return }
        await model.start(isActive: phase == .active)
    }
    func consumeLaunch() { model.consumeLaunch() }
    func openURL(_ url: URL) { model.openURL(url) }
}

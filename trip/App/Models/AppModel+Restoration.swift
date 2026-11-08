import Foundation

extension AppModel {
    func restore(tab: String, tripID: String, initialTripID: UUID?) async {
        guard !Task.isCancelled, !navigation.didRestore else { return }
        let generation = navigation.beginRequest()
        let state = AppRestoration(tab: AppTab(rawValue: tab) == .trips ? .trips : .explore,
                                   tripID: initialTripID ?? UUID(uuidString: tripID), opensTrip: initialTripID != nil)
        await resolve(AppRequest(operation: .destination(.restoration(state))), generation: generation)
        if navigation.generation == generation, !trips.library.isReady || Task.isCancelled { navigation.didRestore = false }
    }

    func applyRestoration(_ state: AppRestoration) {
        navigation.tab = state.tab
        guard let id = state.tripID, trips.library.trip(id) != nil else { return }
        if state.opensTrip { openSavedTrip(id) }
        else { trips.openHostTrip(id, resetDestination: false) }
    }
}

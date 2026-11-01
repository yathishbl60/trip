import TripDomain
import SwiftUI

extension TripController {
    var searchQuery: Binding<String> {
        Binding(get: { model.presentation.searchQuery }, set: { model.presentation.searchQuery = $0 })
    }

    var sortOrder: Binding<TripSortOrder> {
        Binding(get: { model.presentation.sortOrder }, set: { model.presentation.sortOrder = $0 })
    }

    var selection: Binding<UUID?> { Binding(get: { model.selectedTripID }, set: model.selectTrip) }
    var compactColumn: Binding<NavigationSplitViewColumn> {
        Binding(get: { model.presentation.compactColumn }, set: { model.presentation.compactColumn = $0 })
    }
    func reconcileSelection() { model.reconcileSelection() }

    func retrySave() { Task { await model.library.flush() } }
    func duplicate(_ trip: TripPlan) { model.library.duplicate(trip) }
    func explore() { model.environment.showExplore() }
}

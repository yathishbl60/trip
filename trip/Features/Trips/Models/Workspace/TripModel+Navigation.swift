import TripDomain
import Foundation
import SwiftUI

extension TripModel {
    var visibleTrips: [TripPlan] {
        library.filteredTrips(query: presentation.searchQuery, sortOrder: presentation.sortOrder)
    }

    var selectedTripID: UUID? { presentation.selectedTripID }

    func selectTripFromLibrary(_ id: UUID?) {
        let previous = selectedTripID
        selectTrip(id)
        guard let id, id != previous, selectedTripID == id, let trip = library.trip(id) else { return }
        environment.didOpenTrip(trip)
    }

    func selectTrip(_ id: UUID?) {
        if let id, library.trip(id) == nil { return }
        presentation.compactColumn = id == nil ? .sidebar : .detail
        guard selectedTripID != id else { return }
        dismissAssistant()
        presentation.detailRoute = nil
        presentation.dayToDelete = nil
        presentation.collectionToDelete = nil
        presentation.collectionDraft = nil
        presentation.checklistDraft = nil
        presentation.savedPlacePicker = nil
        presentation.stopOrder = nil
        presentation.daySchedule = nil
        presentation.stopTiming = nil
        clearJourneyPresentation()
        presentation.selectedTripID = id
    }

    func reconcileSelection() {
        if let id = selectedTripID, library.isReady, library.trip(id) == nil { selectTrip(nil) }
    }

    private func clearJourneyPresentation() {
        if let draft = presentation.planning { closePlanning(draft.id) }
        dismissPacking()
        lookup.cancel()
        presentation.eventDraft = nil
        presentation.notice = nil
    }

    func openLookup(_ tripID: UUID, question: String = "") {
        guard let trip = library.trip(tripID) else { return }
        lookup.prepare(trip, question: question)
        presentation.detailRoute = TripDetailRoute(tripID: tripID, destination: .lookup)
    }

    func lookupSnapshot(_ tripID: UUID) -> TripSurfacePlan? {
        library.trip(tripID).map(TripSurfacePlan.init)
    }

    func openDetail(_ destination: TripDetailRoute.Destination, tripID: UUID) {
        guard library.trip(tripID) != nil, presentation.detailRoute == nil else { return }
        presentation.detailRoute = TripDetailRoute(tripID: tripID, destination: destination)
    }

    func dismissDetail(_ route: TripDetailRoute?) {
        guard presentation.detailRoute == route else { return }
        presentation.detailRoute = nil
    }
}

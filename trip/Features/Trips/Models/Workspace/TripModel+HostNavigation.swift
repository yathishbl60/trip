import Foundation
import TripDomain

extension TripModel {
    @discardableResult func openHostTrip(_ id: UUID, resetDestination: Bool) -> Bool {
        guard !hasEditingSession, library.trip(id) != nil else { return false }
        dismissAssistant()
        selectTrip(id)
        if resetDestination { presentation.detailRoute = nil }
        return true
    }

    func openHostLibrary() {
        guard !hasEditingSession else { return }
        selectTrip(nil)
    }

    func openHostDetail(_ identity: TripDetailIdentity, editing: Bool) {
        guard !hasEditingSession, let plan = library.trip(identity.tripID),
              identity.resolve(in: TripSurfacePlan(plan)) != nil else { return }
        openLookup(identity.tripID)
        lookup.chooseDetail(identity.itemID)
        if editing { editSavedDetail(identity.itemID, tripID: identity.tripID) }
    }

    func supportsHostReview(_ tool: TripWorkspaceTool) -> Bool {
        tool == .tripDetails || systemActions.service.supportsCalendarReminders
    }

    func openHostCollection(_ identity: TripCollectionIdentity) {
        guard !hasEditingSession, let plan = library.trip(identity.tripID), identity.resolve(in: plan) != nil else { return }
        let route = TripDetailRoute(tripID: plan.id, destination: .collection(identity.collectionID))
        guard !TripDetailRoute.sameDestination(presentation.detailRoute, route) else { return }
        presentation.detailRoute = route
    }
}

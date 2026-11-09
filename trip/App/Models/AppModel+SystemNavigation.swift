import Foundation
import TripDomain

extension AppModel {
    func openDestination(_ destination: AppDestination) {
        switch destination {
        case .explore: navigation.tab = .explore
        case .trips: openTripLibrary()
        case .savedTrip(let id): openSavedTrip(id)
        case .detail(let identity): openDetail(identity)
        case .collection(let identity): openCollection(identity)
        case .section(let id, let section):
            guard openSavedTrip(id, resetDestination: false) else { return }
            trips.openSection(section, tripID: id)
        case .linkedDetail(let id, let item): openLinkedDetail(item, tripID: id)
        case .restoration(let state): applyRestoration(state)
        }
    }

    func openWorkflow(_ request: AppWorkflowRequest) {
        switch request {
        case .newTrip: openNewTrip()
        case .draftTrip(let id, let preferences, let days, let processing):
            guard openSavedTrip(id) else { return }
            trips.openHostDraft(id, preferences: preferences, days: days, processing: processing)
        case .findTrip(let id, let question):
            guard openSavedTrip(id) else { return }
            trips.openLookup(id, question: question)
        case .checklist(let id, let preferences): openChecklist(id, preferences: preferences)
        case .searchPlace(let request): openPlaceSearch(request)
        case .importBooking(let request): openBookingImport(request)
        case .workspaceTool(let id, let tool): openReview(tool, tripID: id)
        case .dayTool(let id, let dayID, let tool): openDayTool(tool, tripID: id, dayID: dayID)
        case .editDetail(let identity): openDetail(identity, editing: true)
        case .newEvent(let request): openNewEvent(request)
        case .bookingAlarm(let identity): openBookingAlarm(identity)
        }
    }

    func openDetail(_ identity: TripDetailIdentity, editing: Bool = false) {
        guard validateDetail(identity), openSavedTrip(identity.tripID, resetDestination: false) else { return }
        trips.openHostDetail(identity, editing: editing)
    }

    private func openCollection(_ identity: TripCollectionIdentity) {
        guard let plan = navigationPlan(identity.tripID), identity.resolve(in: plan) != nil,
              openSavedTrip(identity.tripID, resetDestination: false) else { return }
        trips.openHostCollection(identity)
    }

    @discardableResult func openSavedTrip(_ id: UUID, resetDestination: Bool = true) -> Bool {
        guard allowNavigation(), navigationPlan(id) != nil else { return false }
        guard trips.openHostTrip(id, resetDestination: resetDestination) else { return false }
        navigation.tab = .trips
        return true
    }
}

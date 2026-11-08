import Foundation
import TripDomain

extension AppModel {
    func openNewTrip() {
        navigation.tab = .trips
        trips.beginCreate()
    }

    func openTripLibrary() {
        guard allowNavigation() else { return }
        navigation.tab = .trips
        trips.openHostLibrary()
    }

    func openDayTool(_ tool: TripDayTool, tripID: UUID, dayID: UUID) {
        let opensItinerary = tool == .directions || tool == .stopOrder
        guard openSavedDay(tripID, dayID: dayID, resetDestination: opensItinerary) else { return }
        trips.openDayTool(tool, dayID: dayID, tripID: tripID)
    }

    func openPlaceSearch(_ request: TripPlaceSearchRequest) {
        guard openSavedDay(request.tripID, dayID: request.dayID, resetDestination: true) else { return }
        trips.openHostPlaceSearch(tripID: request.tripID, dayID: request.dayID, query: request.query)
    }

    func openBookingImport(_ request: TripBookingImportRequest) {
        guard openSavedDay(request.tripID, dayID: request.dayID, resetDestination: true) else { return }
        trips.openHostBookingImport(tripID: request.tripID, dayID: request.dayID, document: request.document)
    }

    func openChecklist(_ id: UUID, preferences: String? = nil) {
        guard openSavedTrip(id) else { return }
        trips.openHostChecklist(id, preferences: preferences)
    }

    func openReview(_ tool: TripWorkspaceTool, tripID: UUID) {
        guard trips.supportsHostReview(tool) else {
            navigation.notice = TripSystemActionError.unavailable.errorDescription
            return
        }
        guard openSavedTrip(tripID, resetDestination: false) else { return }
        trips.openWorkspaceTool(tool, tripID: tripID)
    }

    func openBookingAlarm(_ identity: TripDetailIdentity) {
        guard allowNavigation(), let plan = navigationPlan(identity.tripID) else { return }
        do {
            guard trips.supportsHostBookingAlarms else { throw TripSystemActionError.unavailable }
            try TripBookingAlarmIntentError.validate(identity, in: plan)
            guard openSavedTrip(identity.tripID, resetDestination: false) else { return }
            trips.openHostBookingAlarm(identity)
        } catch { navigation.notice = error.localizedDescription }
    }
}

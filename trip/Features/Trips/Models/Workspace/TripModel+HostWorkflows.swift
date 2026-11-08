import Foundation
import TripDomain

extension TripModel {
    var hasPendingPlaceSave: Bool { presentation.placeSave != nil }
    var supportsHostBookingAlarms: Bool { systemActions.service.supportsAlarms }

    func openHostBookingAlarm(_ identity: TripDetailIdentity) {
        guard !hasEditingSession, supportsHostBookingAlarms, let trip = library.trip(identity.tripID),
              let event = trip.events.first(where: { $0.id == identity.itemID }),
              event.dayRange(in: trip) != nil else { return }
        openHostDetail(identity, editing: false)
        systemActions.showAlarm(tripID: identity.tripID, eventID: identity.itemID)
    }

    func openHostDraft(_ id: UUID, preferences: String, days: Int, processing: TripAIProcessing) {
        guard !hasEditingSession, library.trip(id) != nil else { return }
        openAssistant(id)
        assistant.setProcessing(processing)
        assistant.setPreferences(preferences)
        assistant.setDayCount(days)
        generatePlan(id)
    }

    func openHostPlaceSearch(tripID: UUID, dayID: UUID, query: String) {
        guard !hasEditingSession else { return }
        beginSavedPlaces(dayID: dayID, tripID: tripID)
        presentation.savedPlacePicker?.setQuery(query)
    }

    func openHostBookingImport(tripID: UUID, dayID: UUID, document: TripBookingDocument) {
        guard !hasEditingSession else { return }
        beginBookingImport(tripID: tripID, dayID: dayID)
        bookingImport.load(document)
    }

    func openHostChecklist(_ id: UUID, preferences: String?) {
        guard !hasEditingSession, library.trip(id) != nil else { return }
        openSection(.checklist, tripID: id)
        if let preferences {
            checklist.openPacking(id)
            checklist.setPackingPreferences(preferences)
        }
    }

    func suspendHostServices() {
        assistant.cancel()
        lookup.cancel()
        checklist.cancelPacking()
        presentation.savedPlacePicker?.cancelSearch()
        bookingImport.cancelReading()
        weather.cancel()
    }
}

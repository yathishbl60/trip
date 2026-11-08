import Foundation
import TripDomain

extension TripModel {
    var hasPendingPlaceSave: Bool { presentation.placeSave != nil }

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

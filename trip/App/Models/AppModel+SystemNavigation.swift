import TripLocalization
import Foundation
import TripDomain

extension AppModel {
    func request(_ destination: AppDestination) {
        cancelPendingLink()
        guard allowNavigation() else { return }
        switch destination {
        case .explore: showExplore()
        case .trips: openTripLibrary()
        case .savedTrip(let id): openSavedTrip(id)
        case .newTrip: createNewTrip()
        case .draftTrip(let id, let preferences, let days, let processing):
            draftTrip(id, preferences: preferences, days: days, processing: processing)
        case .findTrip(let id, let question):
            findTrip(id, question: question)
        case .savedDetail(let identity): openDetail(identity)
        case .checklist(let id, let preferences): openChecklist(id, preferences: preferences)
        case .searchPlace(let request): openPlaceSearch(request)
        case .importBooking(let request): openBookingImport(request)
        default: openWorkspace(destination)
        }
    }

    private func createNewTrip() {
        navigation.tab = .trips
        trips.beginCreate()
    }

    private func findTrip(_ id: UUID, question: String) {
        guard openSavedTrip(id) else { return }
        trips.openLookup(id, question: question)
    }

    func openDetail(_ identity: TripDetailIdentity) {
        guard openSavedTrip(identity.tripID) else { return }
        trips.openLookup(identity.tripID)
        trips.lookup.chooseDetail(identity.itemID)
    }

    private func draftTrip(_ id: UUID, preferences: String, days: Int, processing: TripAIProcessing) {
        guard openSavedTrip(id) else { return }
        trips.openAssistant(id)
        trips.assistant.setProcessing(processing)
        trips.assistant.setPreferences(preferences)
        trips.assistant.setDayCount(days)
        trips.generatePlan(id)
    }

    @discardableResult func openSavedTrip(_ id: UUID) -> Bool {
        guard allowNavigation() else { return false }
        guard trips.library.isReady else {
            navigation.notice = TripIntentError.libraryUnavailable.errorDescription
            return false
        }
        guard trips.library.trip(id) != nil else {
            navigation.notice = TripIntentError.missingTrip.errorDescription
            return false
        }
        navigation.tab = .trips
        trips.dismissAssistant()
        trips.selectTrip(id)
        trips.presentation.detailRoute = nil
        return true
    }
}

import Foundation
import TripDomain

extension AppModel {
    func openPlaceSearch(_ request: TripPlaceSearchRequest) {
        guard !trips.hasEditingSession else {
            trips.presentation.notice = TripPlaceSearchIntentError.editing.errorDescription
            return
        }
        guard let trip = trips.library.trip(request.tripID) else {
            trips.presentation.notice = TripIntentError.missingTrip.errorDescription
            return
        }
        guard trip.days.contains(where: { $0.id == request.dayID }) else {
            trips.presentation.notice = TripIntentError.missingDay.errorDescription
            return
        }
        guard openSavedTrip(trip.id) else { return }
        trips.presentation.detailRoute = nil
        trips.beginSavedPlaces(dayID: request.dayID, tripID: trip.id)
        trips.presentation.savedPlacePicker?.setQuery(request.query)
    }
}

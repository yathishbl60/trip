import Foundation
import TripDomain

extension AppModel {
    func openBookingImport(_ request: TripBookingImportRequest) {
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
        trips.beginBookingImport(tripID: trip.id, dayID: request.dayID)
        trips.bookingImport.load(request.document)
    }
}

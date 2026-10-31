import Foundation
import TripDomain
import TripLocalization

extension TripModel {
    func beginBookingImport(tripID: UUID, dayID: UUID? = nil) {
        guard !hasEditingSession,
              let trip = library.trip(tripID), let dayID = dayID ?? trip.days.first?.id,
              trip.days.contains(where: { $0.id == dayID }) else { return }
        bookingImport.begin(trip: trip, dayID: dayID)
    }

    func finishBookingImport() {
        guard bookingImport.wantsEventReview else { bookingImport.cancel(); return }
        defer { bookingImport.cancel() }
        guard let original = bookingImport.sourceTrip, let trip = library.trip(original.id),
              let dayID = bookingImport.dayID, !presentation.hasEditingSession, systemActions.presentation == nil,
              trip.days.map(\.id) == original.days.map(\.id), trip.startDate == original.startDate,
              trip.timeZoneID == original.timeZoneID else {
            feedback.show(TripText.bookingDestinationChanged.text)
            return
        }
        let draft = TripEventDraft(trip: trip, dayID: dayID, kind: bookingImport.kind)
        draft.setText(bookingImport.title, at: \.title)
        draft.setText(bookingImport.location, at: \.location)
        draft.setText(bookingImport.arrivalLocation, at: \.arrivalLocation)
        applyBookingTimes(to: draft)
        presentation.eventDraft = draft
    }

    private func applyBookingTimes(to draft: TripEventDraft) {
        let dates = bookingImport.proposal?.dates ?? []
        if let departure = dates.first(where: { $0.id == bookingImport.departureCandidateID }) {
            draft.setClock(departure.clock(zoneID: bookingImport.departureZone), arrival: false)
        }
        if let arrival = dates.first(where: { $0.id == bookingImport.arrivalCandidateID }) {
            draft.setClock(arrival.clock(zoneID: bookingImport.arrivalZone), arrival: true)
        }
    }
}

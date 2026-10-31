import TripLocalization
import Foundation
import Observation
import TripDomain

/// One editing session. Saving merges changed fields into the latest stored trip.
@MainActor @Observable final class TripEditDraft: Identifiable, TripDiscardableDraft {
    let id = UUID()
    let tripID: UUID?
    let placeToSave: Place?
    private let original: TripPlan?
    private let initialStartDate: Date
    private let initialTimeZoneID: String
    var title: String
    var startDate: Date
    var notes: String
    var error: String?
    var timeZoneID: String
    var timeZoneReviewed = false
    var isDiscarding = false
    var calendar: Calendar { TripLocalDate.calendar(zoneID: timeZoneID) }

    init(trip: TripPlan? = nil, placeToSave: Place? = nil) {
        tripID = trip?.id
        original = trip
        self.placeToSave = placeToSave
        title = trip?.title ?? ""
        initialStartDate = trip?.startDate ?? .now
        startDate = initialStartDate
        notes = trip?.notes ?? ""
        initialTimeZoneID = trip?.timeZoneID ?? TimeZone.current.identifier
        timeZoneID = initialTimeZoneID
    }

    var normalizedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    var hasUnsavedChanges: Bool {
        title != (original?.title ?? "") || notes != (original?.notes ?? "")
            || startDate != initialStartDate || timeZoneID != initialTimeZoneID
            || (original?.needsTimeZoneReview == true && timeZoneReviewed)
    }
    var canSave: Bool { !normalizedTitle.isEmpty && validationMessage == nil }
    var navigationTitle: String { tripID == nil ? TripText.newTrip2.text : TripText.editTrip.text }
    var validationMessage: String? {
        if normalizedTitle.count > TripLimits.titleCharacters {
            return TripText.useValueCharactersOrFewerForTheName(TripText.number(TripLimits.titleCharacters)).text
        }
        if notes.count > TripLimits.noteCharacters {
            return TripText.useValueCharactersOrFewerForNotes(TripText.number(TripLimits.noteCharacters)).text
        }
        return nil
    }

    @discardableResult func apply(to trip: inout TripPlan) -> Bool {
        if let original, timeZoneReviewed || original.startDate != startDate,
           trip.startDate != original.startDate || trip.timeZoneID != original.timeZoneID {
            error = TripText.theTripSDateOrTimeZoneChangedElsewhere.text
            return false
        }
        if original?.title != title { trip.title = normalizedTitle }
        if original?.startDate != startDate { trip.startDate = startDate }
        if original?.notes != notes { trip.notes = notes }
        if timeZoneReviewed {
            _ = trip.reviewTimeZone(timeZoneID, departure: TripLocalDate(startDate, calendar: calendar))
        }
        return true
    }

    func reviewTimeZone(_ zoneID: String) {
        let old = TripLocalDate(startDate, calendar: calendar)
        timeZoneID = zoneID
        if let noon = old.noon(in: calendar) { startDate = calendar.startOfDay(for: noon) }
        timeZoneReviewed = true
    }

    var timeZoneMessage: String {
        original?.needsTimeZoneReview == true && !timeZoneReviewed
            ? TripText.olderSchedulesNeedTheirOriginalTimeZoneConfirmedReview.text
            : TripText.calendarDaysUseThisDestinationTimeZoneSavedBookings.text
    }
}

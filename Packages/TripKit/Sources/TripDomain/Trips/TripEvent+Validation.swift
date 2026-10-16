#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

extension TripEvent {
    public nonisolated func dayRange(in trip: TripPlan) -> ClosedRange<Int>? {
        guard let start = trip.days.firstIndex(where: { $0.id == startDayID }),
              let end = trip.days.firstIndex(where: { $0.id == endDayID }), start <= end else { return nil }
        return start...end
    }

    public nonisolated func occurs(on dayID: UUID, in trip: TripPlan) -> Bool {
        guard let range = dayRange(in: trip), let index = trip.days.firstIndex(where: { $0.id == dayID }) else { return false }
        return range.contains(index)
    }

    public nonisolated func validationIssue(in trip: TripPlan) -> String? {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return TripText.giveThisEventATitle.text }
        guard title.count <= TripLimits.titleCharacters, notes.count <= TripLimits.noteCharacters,
              location.count <= TripLimits.noteCharacters, arrivalLocation.count <= TripLimits.noteCharacters else {
            return TripText.shortenTheTitleOrDetailsBeforeSaving.text
        }
        guard dayRange(in: trip) != nil else { return TripText.chooseAnEndDayOnOrAfterTheStart.text }
        guard [startMinute, endMinute].compactMap({ $0 }).allSatisfy({ (0..<1440).contains($0) }) else {
            return TripText.chooseAValidTime.text
        }
        if let clockIssue { return clockIssue }
        if trip.needsTimeZoneReview, startMinute != nil || endMinute != nil {
            return TripText.confirmThisTripSTimeZoneInEditTrip2.text
        }
        if departureTime == nil, arrivalTime == nil, startDayID == endDayID,
           let startMinute, let endMinute, endMinute < startMinute {
            return TripText.endTimeIsEarlierThanStartTimeForOvernight.text
        }
        return nil
    }
}

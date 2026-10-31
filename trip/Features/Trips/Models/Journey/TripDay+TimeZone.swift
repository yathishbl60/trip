import TripLocalization
import TripDomain

extension TripDay {
    func scheduleIssue(in trip: TripPlan) -> String? {
        guard let schedule else { return nil }
        if trip.needsTimeZoneReview { return TripText.confirmTheTripSTimeZoneInEditTrip.text }
        return schedule.clockIssue(on: trip.date(for: self), calendar: trip.calendar)
    }
}

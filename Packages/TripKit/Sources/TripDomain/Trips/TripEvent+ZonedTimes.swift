#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

extension TripEvent {
    public nonisolated var elapsedDuration: TimeInterval? {
        guard let start = departureTime?.instant, let end = arrivalTime?.instant, end >= start else { return nil }
        return end.timeIntervalSince(start)
    }

    public nonisolated var clockIssue: String? {
        if let issue = departureTime?.issue { return "\(kind.startLabel): \(issue)" }
        if let issue = arrivalTime?.issue { return "\(kind.endLabel): \(issue)" }
        if let start = departureTime?.instant, let end = arrivalTime?.instant, end < start {
            return TripText.arrivalIsBeforeDepartureAsAnInstantCheckBoth.text
        }
        return nil
    }

    public nonisolated mutating func reviewLegacyTimes(in trip: TripPlan) {
        guard !trip.needsTimeZoneReview else { return }
        if departureTime == nil { departureTime = legacyTime(startMinute, dayID: startDayID, trip: trip) }
        if arrivalTime == nil { arrivalTime = legacyTime(endMinute, dayID: endDayID, trip: trip) }
    }

    public nonisolated func legacyTime(_ minute: Int?, dayID: UUID, trip: TripPlan) -> TripZonedDateTime? {
        guard let minute, let day = trip.days.first(where: { $0.id == dayID }) else { return nil }
        return TripZonedDateTime(date: TripLocalDate(trip.date(for: day), calendar: trip.calendar),
                                 minute: minute, zoneID: trip.calendar.timeZone.identifier)
    }
}

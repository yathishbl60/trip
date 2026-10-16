#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

extension TripDaySchedule {
    public nonisolated func clock(on date: Date, calendar: Calendar, end: Bool) -> TripZonedDateTime {
        let next = end && endsNextDay ? calendar.date(byAdding: .day, value: 1, to: date) ?? date : date
        var clock = TripZonedDateTime(date: TripLocalDate(next, calendar: calendar),
                                      minute: end ? normalized.endMinute : normalized.startMinute,
                                      zoneID: calendar.timeZone.identifier)
        clock.occurrence = end ? endOccurrence : startOccurrence
        return clock
    }

    public nonisolated func clockIssue(on date: Date, calendar: Calendar) -> String? {
        if let issue = clock(on: date, calendar: calendar, end: false).issue { return TripText.firstArrivalValue(issue).text }
        if let issue = clock(on: date, calendar: calendar, end: true).issue { return TripText.targetFinishValue2(issue).text }
        return nil
    }
}

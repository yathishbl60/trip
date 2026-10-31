import Foundation
import TripDomain

extension TripDayScheduleDraft {
    var utc: Calendar { TripLocalDate.calendar(zoneID: "Etc/UTC") }
    var startClock: TripZonedDateTime? { value?.clock(on: date, calendar: calendar, end: false) }
    var endClock: TripZonedDateTime? { value?.clock(on: date, calendar: calendar, end: true) }
    var clockIssue: String? { value?.clockIssue(on: date, calendar: calendar) }

    func setStart(_ value: Date) { start = value; startOccurrence = .unresolved }
    func setEnd(_ value: Date) { end = value; endOccurrence = .unresolved }
}

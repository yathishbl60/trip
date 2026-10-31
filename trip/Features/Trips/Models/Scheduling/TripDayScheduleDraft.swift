import TripLocalization
import Foundation
import Observation
import TripDomain

@MainActor @Observable final class TripDayScheduleDraft: Identifiable, TripDiscardableDraft {
    let id = UUID()
    let tripID: UUID
    let dayID: UUID
    let title: String
    let date: Date
    let calendar: Calendar
    private let original: TripDaySchedule?
    var enabled = true
    var start: Date
    var end: Date
    var startOccurrence: TripClockOccurrence
    var endOccurrence: TripClockOccurrence
    var error: String?
    var isDiscarding = false

    init(trip: TripPlan, day: TripDay) {
        tripID = trip.id
        dayID = day.id
        title = day.title
        date = trip.date(for: day)
        calendar = trip.calendar
        original = day.schedule
        let schedule = day.schedule ?? TripDaySchedule()
        start = schedule.clock(on: date, calendar: calendar, end: false).pickerDate
        end = schedule.clock(on: date, calendar: calendar, end: true).pickerDate
        startOccurrence = schedule.startOccurrence
        endOccurrence = schedule.endOccurrence
    }

    var value: TripDaySchedule? {
        guard enabled else { return nil }
        return TripDaySchedule(startMinute: TripScheduleClock.minute(of: start, calendar: utc),
                               endMinute: TripScheduleClock.minute(of: end, calendar: utc),
                               startOccurrence: startOccurrence, endOccurrence: endOccurrence)
    }

    var isUnchanged: Bool { value == original }
    var hasUnsavedChanges: Bool { value != (original ?? TripDaySchedule()) }
    var endExplanation: String {
        value?.endsNextDay == true ? TripText.endTimeIsOnTheFollowingDay.text : TripText.stopsBeyondThisTimeAreFlagged.text
    }

    func apply(to day: inout TripDay, on currentDate: Date, calendar current: Calendar) -> Bool {
        if let issue = value?.clockIssue(on: date, calendar: calendar) { error = issue; return false }
        guard calendar.timeZone == current.timeZone, calendar.isDate(date, inSameDayAs: currentDate) else {
            error = TripText.thisDaySDateOrTimeZoneChangedClose.text
            return false
        }
        guard day.schedule == original || day.schedule == value else {
            error = TripText.thisScheduleChangedElsewhereCloseAndReopenItTo.text
            return false
        }
        day.schedule = value
        return true
    }

    func preview(in trip: TripPlan?) -> TripDayTimeline? {
        guard let trip, var day = trip.days.first(where: { $0.id == dayID }) else { return nil }
        day.schedule = value
        return TripDayTimeline(day: day, date: trip.date(for: day), calendar: trip.calendar)
    }
}

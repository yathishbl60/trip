import Foundation

enum TripScheduleClockChecks {
    static func run() throws {
        try springForward()
        try fallBack()
    }

    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return calendar
    }

    private static func springForward() throws {
        let date = calendar.date(from: DateComponents(year: 2026, month: 3, day: 8))!
        let missing = TripScheduleClock.date(minute: 150, on: date, calendar: calendar)
        try require(TripScheduleClock.minute(of: missing, calendar: calendar) == 180, "Missing clock time did not advance")
        var day = TripScheduleFixtures.day()
        day.schedule = TripDaySchedule(startMinute: 90, endMinute: 240)
        day.stops = [day.stops[0]]
        day.stops[0].timing.visitMinutes = 120
        let timeline = TripDayTimeline(day: day, date: date, calendar: calendar)!
        try require(timeline.end.timeIntervalSince(timeline.start) == 7_200, "DST changed elapsed visit duration")
        try require(TripScheduleClock.minute(of: timeline.end, calendar: calendar) == 270, "Spring-forward departure incorrect")
        try require(timeline.overrunMinutes == 30, "DST target finish uses elapsed rather than wall-clock time")
    }

    private static func fallBack() throws {
        let date = calendar.date(from: DateComponents(year: 2026, month: 11, day: 1))!
        let start = TripScheduleClock.date(minute: 30, on: date, calendar: calendar)
        let repeated = TripScheduleClock.date(minute: 90, on: date, calendar: calendar)
        try require(repeated.timeIntervalSince(start) == 3_600, "Repeated fixed time should use its first occurrence")
        let next = TripScheduleClock.date(minute: 1500, on: date, calendar: calendar)
        try require(TripScheduleClock.offset(of: next, from: date, calendar: calendar) == 1500, "DST broke next-day offset")
        try require(TripScheduleClock.minute(of: next, calendar: calendar) == 60, "Next-day wall clock changed")
    }
}

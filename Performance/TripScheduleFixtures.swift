import Foundation

nonisolated enum TripScheduleFixtures {
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    static var date: Date { calendar.date(from: DateComponents(year: 2026, month: 10, day: 11))! }

    static func day() -> TripDay {
        var day = TripDay(number: 1)
        day.schedule = TripDaySchedule(startMinute: 540, endMinute: 720)
        day.stops = (0..<3).map { TripStop(place: CheckFixtures.place("timed-\($0)")) }
        day.stops[0].timing = TripStopTiming(visitMinutes: 60, travelMinutes: 720, bufferMinutes: 180)
        day.stops[1].timing = TripStopTiming(visitMinutes: 45, travelMinutes: 20, bufferMinutes: 10)
        day.stops[2].timing = TripStopTiming(visitMinutes: 30, travelMinutes: 0, bufferMinutes: 0)
        return day
    }

    static func timeline(_ day: TripDay) throws -> TripDayTimeline {
        guard let timeline = TripDayTimeline(day: day, date: date, calendar: calendar) else {
            throw CheckFailure(description: "Scheduled fixture has no timeline")
        }
        return timeline
    }

    static func minute(_ date: Date) -> Int { TripScheduleClock.minute(of: date, calendar: calendar) }
}

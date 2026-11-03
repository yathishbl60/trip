import Foundation

enum TripScheduleChecks {
    static func run() throws {
        try TripPlanningChecks.run()
        try sequential()
        try fixedArrivals()
        try reorder()
        try overnightAndDisabled()
        try TripSchedulePersistenceChecks.run()
        try TripScheduleClockChecks.run()
    }

    private static func sequential() throws {
        let day = TripScheduleFixtures.day()
        let timeline = try TripScheduleFixtures.timeline(day)
        let entries = timeline.entries
        try require(entries.map(\.id) == day.stops.map(\.id), "Timeline changed stop identities or order")
        try require(TripScheduleFixtures.minute(entries[0].arrival) == 540, "First arrival lost day start")
        try require(entries[0].travelMinutes == 0 && entries[0].bufferMinutes == 0, "First stop gained a transfer")
        try require(TripScheduleFixtures.minute(entries[1].arrival) == 630, "Travel and buffer not included")
        try require(TripScheduleFixtures.minute(timeline.end) == 705, "Visit duration or zero transfer incorrect")
        try require(timeline.overrunMinutes == 0 && timeline.conflictCount == 0, "Valid schedule has warnings")
        try require(timeline[day.stops[1].id]?.arrival == entries[1].arrival, "Identity lookup differs from timeline")
    }

    private static func fixedArrivals() throws {
        var day = TripScheduleFixtures.day()
        day.stops[0].timing.visitMinutes = 90
        day.stops[1].timing.arrivalMinute = 600
        day.stops[2].timing = TripStopTiming(arrivalMinute: 750, visitMinutes: 30)
        let timeline = try TripScheduleFixtures.timeline(day)
        try require(timeline.entries[1].lateMinutes == 60, "Unreachable reservation not flagged")
        try require(TripScheduleFixtures.minute(timeline.entries[1].fixedArrival!) == 600, "Fixed arrival was changed")
        try require(timeline.entries[2].waitingMinutes == 20, "Free time before a fixed arrival lost")
        try require(timeline.conflictCount == 1 && timeline.overrunMinutes == 60, "Day warnings incorrect")
        try require(TripScheduleFixtures.minute(timeline.end) == 780, "Fixed arrival did not propagate")
    }

    private static func reorder() throws {
        var day = TripScheduleFixtures.day()
        day.stops = Array(day.stops.prefix(2))
        day.stops[0].timing = TripStopTiming(visitMinutes: 60)
        day.stops[1].timing = TripStopTiming(arrivalMinute: 600, visitMinutes: 60, travelMinutes: 0, bufferMinutes: 0)
        let original = try TripScheduleFixtures.timeline(day)
        day.stops.swapAt(0, 1)
        let reordered = try TripScheduleFixtures.timeline(day)
        try require(reordered.entries.map(\.id) == day.stops.map(\.id), "Reordered timeline retained old ordering")
        try require(reordered[day.stops[1].id]?.arrival != original[day.stops[1].id]?.arrival, "Arrival did not recalculate")
        try require(TripScheduleFixtures.minute(reordered.entries[1].arrival) == 685, "Incoming allowance lost after move")
        try require(day.stops[0].timing.arrivalMinute == 600, "Reordering cleared a reservation")
    }

    private static func overnightAndDisabled() throws {
        var day = TripScheduleFixtures.day()
        day.schedule = nil
        try require(TripDayTimeline(day: day, date: TripScheduleFixtures.date) == nil, "Disabled schedule visible")
        day.schedule = TripDaySchedule(startMinute: 1320, endMinute: 60)
        day.stops[1].timing.arrivalMinute = 1440
        let timeline = try TripScheduleFixtures.timeline(day)
        try require(timeline.entries[1].waitingMinutes == 30, "Next-day fixed arrival lost")
        try require(timeline.overrunMinutes == 15, "Overnight target finish incorrect")
        day.stops = []
        day.schedule = TripDaySchedule(startMinute: 540, endMinute: 540)
        let empty = try TripScheduleFixtures.timeline(day)
        try require(empty.end == empty.start && empty.overrunMinutes == 0, "Empty day consumes time")
        try require(empty.targetEnd.timeIntervalSince(empty.start) == 86_400, "Equal start/end should mean next day")
    }
}

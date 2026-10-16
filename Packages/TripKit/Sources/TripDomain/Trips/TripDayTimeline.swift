import Foundation

/// A deterministic schedule built from the current order, durations, and fixed arrivals.
public nonisolated struct TripDayTimeline: Sendable {
    public let start: Date
    public let targetEnd: Date
    public let entries: [TripTimelineEntry]
    public let calendar: Calendar
    private let byID: [UUID: TripTimelineEntry]

    public init?(day: TripDay, date: Date, calendar: Calendar = .current) {
        guard let schedule = day.schedule?.normalized,
              let first = schedule.clock(on: date, calendar: calendar, end: false).instant,
              let last = schedule.clock(on: date, calendar: calendar, end: true).instant else { return nil }
        self.calendar = calendar
        start = first
        targetEnd = last
        var cursor = TripTimelineCursor(next: start, date: date, calendar: calendar)
        let entries = day.stops.enumerated().map { cursor.append($0.element, first: $0.offset == 0) }
        self.entries = entries
        byID = Dictionary(entries.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    public var end: Date { entries.last?.departure ?? start }
    public var overrunMinutes: Int { max(0, Int(ceil(end.timeIntervalSince(targetEnd) / 60))) }
    public var conflictCount: Int { entries.count { $0.lateMinutes > 0 } }
    public subscript(stopID: UUID) -> TripTimelineEntry? { byID[stopID] }
}

private nonisolated struct TripTimelineCursor {
    var next: Date
    let date: Date
    let calendar: Calendar

    mutating func append(_ stop: TripStop, first: Bool) -> TripTimelineEntry {
        let timing = stop.timing.normalized
        let travel = first ? 0 : timing.travelMinutes
        let buffer = first ? 0 : timing.bufferMinutes
        let earliest = next.addingTimeInterval(Double(travel + buffer) * 60)
        let clock = timing.arrivalClock(on: date, calendar: calendar)
        let fixed = clock?.instant
        let arrival = max(earliest, fixed ?? earliest)
        let departure = arrival.addingTimeInterval(Double(timing.visitMinutes) * 60)
        let entry = TripTimelineEntry(id: stop.id, day: date, arrival: arrival, departure: departure,
                                      fixedArrival: fixed, visitMinutes: timing.visitMinutes,
                                      travelMinutes: travel, bufferMinutes: buffer,
                                      waitingMinutes: max(0, Int(arrival.timeIntervalSince(earliest) / 60)),
                                      timeZoneID: calendar.timeZone.identifier, arrivalIssue: clock?.issue)
        next = departure
        return entry
    }
}

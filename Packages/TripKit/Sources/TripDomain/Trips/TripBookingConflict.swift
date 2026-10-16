import Foundation

public nonisolated struct TripBookingConflict: Identifiable, Sendable {
    public var id: String { "\(stopID)-\(eventID)" }
    public let stopID: UUID
    public let eventID: UUID
    public let bookingTitle: String

    public static func find(in trip: TripPlan, timeline: TripDayTimeline?) -> [Self] {
        guard let timeline, !trip.needsTimeZoneReview else { return [] }
        return trip.events.flatMap { event in
            let intervals = intervals(for: event, in: trip)
            return timeline.entries.compactMap { entry -> Self? in
                guard intervals.contains(where: { overlaps(entry, interval: $0) }) else { return nil }
                return Self(stopID: entry.id, eventID: event.id, bookingTitle: event.title)
            }
        }
    }

    private static func intervals(for event: TripEvent, in trip: TripPlan) -> [ClosedRange<Date>] {
        let start = (event.departureTime ?? event.legacyTime(event.startMinute, dayID: event.startDayID, trip: trip))?.instant
        let end = (event.arrivalTime ?? event.legacyTime(event.endMinute, dayID: event.endDayID, trip: trip))?.instant
        guard event.kind != .freeTime else { return [] }
        if event.kind == .stay { return [start, end].compactMap { $0.map { $0...$0 } } }
        if let start, let end, end >= start { return [start...end] }
        return [start, end].compactMap { $0.map { $0...$0 } }
    }

    private static func overlaps(_ entry: TripTimelineEntry, interval: ClosedRange<Date>) -> Bool {
        // Include travel and buffer: a booking can conflict before the visit starts.
        let start = entry.arrival.addingTimeInterval(-Double(entry.travelMinutes + entry.bufferMinutes) * 60)
        return interval.lowerBound < entry.departure && interval.upperBound > start
            || interval.lowerBound == interval.upperBound && (start..<entry.departure).contains(interval.lowerBound)
    }
}

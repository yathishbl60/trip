import Foundation

nonisolated enum TripTodayProjection {
    static func items(trip: TripPlan, day: TripDay, journey: TripJourney?) -> [TripTodayItem] {
        let timeline = TripDayTimeline(day: day, date: trip.date(for: day), calendar: trip.calendar)
        let surfaces = Dictionary(TripSurfaceAgenda.items(in: trip, day: day).map { ($0.id, $0) },
                                  uniquingKeysWith: { first, _ in first })
        let visited = journey?.tripID == trip.id && journey?.dayID == day.id ? Set(journey?.visited ?? []) : []
        return trip.journeyItems(on: day).map {
            project($0, surface: surfaces[$0.id], timeline: timeline, trip: trip, day: day, visited: visited)
        }
    }

    private static func project(_ item: TripJourneyItem, surface: TripSurfaceItem?, timeline: TripDayTimeline?,
                                trip: TripPlan, day: TripDay, visited: Set<UUID>) -> TripTodayItem {
        switch item {
        case .visit(let stop): return visit(stop, surface: surface, timeline: timeline, trip: trip, day: day, visited: visited)
        case .event(let event): return eventItem(event, surface: surface, trip: trip, day: day)
        }
    }

    private static func visit(_ stop: TripStop, surface: TripSurfaceItem?, timeline: TripDayTimeline?,
                              trip: TripPlan, day: TripDay, visited: Set<UUID>) -> TripTodayItem {
        let entry = timeline?[stop.id]
        let scheduleIssue = day.schedule?.clockIssue(on: trip.date(for: day), calendar: trip.calendar)
        let review = trip.needsTimeZoneReview || surface?.requiresTimeReview == true || scheduleIssue != nil
        let estimate = surface?.startsAt == nil
        let validForecast = timeline?.entries.allSatisfy { $0.arrivalIssue == nil } == true
        let time = review ? nil : (surface?.startsAt ?? (validForecast ? entry?.arrival : nil))
        let allowance = stop.timing.normalized.travelMinutes + stop.timing.normalized.bufferMinutes
        return TripTodayItem(item: .visit(stop), startsAt: time, endsAt: entry?.departure,
                             leaveBy: time?.addingTimeInterval(-Double(allowance) * 60),
                             zoneID: trip.calendar.timeZone.identifier, requiresTimeReview: review,
                             isEstimate: estimate, isVisited: visited.contains(stop.id))
    }

    private static func eventItem(_ event: TripEvent, surface: TripSurfaceItem?, trip: TripPlan, day: TripDay) -> TripTodayItem {
        let review = surface?.requiresTimeReview == true
        let checkout = event.kind == .stay && event.endDayID == day.id && event.startDayID != day.id
        let start = review ? nil : (checkout ? surface?.endsAt : surface?.startsAt)
        let allowance = event.travelAllowanceMinutes.map { min(1440, max(0, $0)) }
        let leave = start.flatMap { time in allowance.map { time.addingTimeInterval(-Double($0) * 60) } }
        return TripTodayItem(item: .event(event), startsAt: start, endsAt: surface?.endsAt, leaveBy: leave,
                             zoneID: checkout ? (surface?.endZoneID ?? trip.calendar.timeZone.identifier)
                                : (surface?.startZoneID ?? trip.calendar.timeZone.identifier),
                             requiresTimeReview: review, isEstimate: false, isVisited: false)
    }
}

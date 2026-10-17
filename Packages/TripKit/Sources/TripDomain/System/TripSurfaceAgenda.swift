#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

public nonisolated enum TripSurfaceAgenda {
    public static func items(in plan: TripPlan, day: TripDay) -> [TripSurfaceItem] {
        let date = plan.date(for: day)
        return plan.journeyItems(on: day).prefix(TripLimits.stops + TripLimits.events).map { item in
            switch item {
            case .visit(let stop):
                let clock = stop.timing.arrivalClock(on: date, calendar: plan.calendar)
                var result = TripSurfaceItem(id: stop.id, title: stop.place.name, symbol: stop.place.category.symbol,
                                             startsAt: clock?.instant, startZoneID: plan.timeZoneID)
                result.requiresTimeReview = plan.needsTimeZoneReview || clock?.issue != nil
                return result
            case .event(let event): return projected(event, in: plan)
            }
        }
    }

    private static func projected(_ event: TripEvent, in plan: TripPlan) -> TripSurfaceItem {
        let start = event.departureTime == nil ? boundary(event.startMinute, dayID: event.startDayID, plan: plan) : event.departureTime?.instant
        let end = event.arrivalTime == nil ? boundary(event.endMinute, dayID: event.endDayID, plan: plan) : event.arrivalTime?.instant
        let location = [event.location, event.arrivalLocation].filter { !$0.isEmpty }.joined(separator: " → ")
        var item = TripSurfaceItem(id: event.id, title: event.title, symbol: event.kind.symbol,
                               kind: event.kind, detail: location, startsAt: start, endsAt: end,
                               startZoneID: event.departureTime?.zoneID ?? plan.timeZoneID,
                               endZoneID: event.arrivalTime?.zoneID ?? plan.timeZoneID)
        item.requiresTimeReview = event.clockIssue != nil || plan.needsTimeZoneReview
        return item
    }

    private static func boundary(_ minute: Int?, dayID: UUID, plan: TripPlan) -> Date? {
        guard let minute, let day = plan.days.first(where: { $0.id == dayID }) else { return nil }
        return eventTime(minute: minute, day: day, plan: plan)
    }

    private static func eventTime(minute: Int, day: TripDay, plan: TripPlan) -> Date? {
        let value = TripZonedDateTime(date: TripLocalDate(plan.date(for: day), calendar: plan.calendar),
                                      minute: minute, zoneID: plan.calendar.timeZone.identifier)
        return value.instant
    }

    public static func upcoming(in day: TripSurfaceDay, at date: Date) -> [TripSurfaceItem] {
        day.agenda.filter { item in
            if item.requiresTimeReview == true { return true }
            guard let boundary = item.endsAt ?? item.startsAt else { return true }
            return boundary >= date
        }
    }

    public static func description(_ day: TripSurfaceDay) -> String {
        let title = TripText.dayValueValue2(TripText.number(day.number), day.dateText).text
        guard !day.agenda.isEmpty else { return TripText.valueNothingPlannedYet(title).text }
        let items = day.agenda.map { "\($0.title), \($0.timeText)" }.joined(separator: "; ")
        return "\(title): \(items)"
    }
}

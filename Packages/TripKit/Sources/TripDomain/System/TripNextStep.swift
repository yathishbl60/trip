#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

/// A saved next item for an active visit session or the trip's current local day.
public nonisolated struct TripNextStep: Sendable {
    public let plan: TripSurfacePlan
    public let day: TripSurfaceDay?
    public let item: TripSurfaceItem?
    public let isTracking: Bool

    public init(plan: TripSurfacePlan, journey: TripJourney?, at date: Date) {
        self.plan = plan
        let matching = journey?.tripID == plan.id ? journey : nil
        let active = matching?.isActive == true && (matching?.expiresAt ?? date) > date
        let tracked = active ? plan.days.first { $0.id == matching?.dayID } : nil
        isTracking = tracked != nil
        day = tracked ?? plan.days.first { $0.calendar.isDate($0.date, inSameDayAs: date) }
        if let tracked, let stop = matching?.nextStop(in: tracked) {
            item = tracked.agenda.first { $0.id == stop.id } ?? TripSurfaceItem(stop)
        } else if let day, tracked == nil {
            let visited = matching?.dayID == day.id ? Set(matching?.visited ?? []) : []
            item = TripSurfaceAgenda.prioritized(in: day, at: date, excluding: visited).first
        } else { item = nil }
    }

    public var result: TripDetailResult? {
        guard let item, let day else { return nil }
        return TripDetailResult(item: item, day: day)
    }
    public var coordinate: Coordinate? {
        guard let stop = day?.stops.first(where: { $0.id == item?.id }), stop.coordinate.isValid else { return nil }
        return stop.coordinate
    }
    public var heading: String { isTracking ? TripText.nextPlace.text : TripText.upNext.text }
    public var summary: String {
        guard let day else { return TripText.noItineraryPlannedForTodayInValue(plan.title).text }
        if isTracking, item == nil { return TripText.allPlacesVisitedForDayValueOfValue(TripText.number(day.number), plan.title).text }
        guard let item else { return TripText.nothingElsePlannedForDayValueOfValue(TripText.number(day.number), plan.title).text }
        return TripText.valueInValueValueValue(heading, plan.title, item.title, item.timeText).text
    }
}

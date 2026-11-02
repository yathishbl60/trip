import TripLocalization
import TripDomain
import WidgetKit
import Foundation

nonisolated struct TripWidgetEntry: TimelineEntry {
    let date: Date
    var plan: TripSurfacePlan?
    var day: TripSurfaceDay?
    var journey: TripJourney?
    var notice = TripText.createATripToSeeYourItinerary.text

    var title: String { plan?.title ?? TripText.yourTrips.text }
    var url: URL? {
        if let plan, let item {
            return TripSystemData.detailURL(tripID: plan.id, itemID: item.id)
        }
        return plan.flatMap { TripSystemData.tripURL($0.id) } ?? TripSystemData.tripsURL
    }
    var stop: TripSurfaceStop? {
        guard let day else { return nil }
        return journey == nil ? day.stops.first : journey?.nextStop(in: day)
    }
    var isTracking: Bool { journey?.isActive == true && (journey?.expiresAt ?? date) > date }
    var visited: Int { journey?.visited.count ?? 0 }
    var total: Int { day?.stops.count ?? 0 }
    var progress: String { TripText.valueOfValueVisited(TripText.number(visited), TripText.number(total)).text }
    var subtitle: String {
        guard let day else { return plan == nil ? notice : TripText.noUpcomingDaysPlanned.text }
        return TripText.dayValueValue(TripText.number(day.number), day.dateText).text
    }
    var stopTitle: String {
        if let item { return item.title }
        if let journey, !journey.isActive, visited == total, total > 0 { return TripText.allPlacesVisited.text }
        return plan == nil ? TripText.openTripToGetStarted.text : TripText.nothingElsePlanned.text
    }
    var item: TripSurfaceItem? {
        if isTracking, let journey, let day {
            guard let stop = journey.nextStop(in: day) else { return nil }
            return day.agenda.first { $0.id == stop.id } ?? TripSurfaceItem(stop)
        }
        return upcoming.first
    }
    var upcoming: [TripSurfaceItem] {
        guard let day else { return [] }
        return TripSurfaceAgenda.prioritized(in: day, at: date, excluding: Set(journey?.visited ?? []))
    }
    var remaining: [TripSurfaceItem] { Array(upcoming.filter { $0.id != item?.id }.prefix(2)) }
    var timeText: String? {
        item?.requiresTimeReview == true ? item?.timeText : (item?.startsAt == nil && item?.endsAt == nil ? nil : item?.timeText)
    }
    var detail: String { timeText.map { "\(subtitle) · \($0)" } ?? subtitle }
    var directionsURL: URL? {
        guard let item, let stop = day?.stops.first(where: { $0.id == item.id }),
              stop.coordinate.isValid else { return nil }
        return TripSystemData.directionsURL(stop.coordinate)
    }
}

import Foundation
import TripDomain

extension TripModel {
    func today(_ tripID: UUID, at now: Date) -> TripTodayModel? {
        guard let trip = library.trip(tripID) else { return nil }
        return TripTodayModel(snapshot: TripTodaySnapshot(trip: trip, at: now, journey: tracking.runtime?.journey), now: now)
    }

    func openTodayItem(_ item: TripTodayItem, tripID: UUID, directions: Bool) {
        guard let trip = library.trip(tripID) else { return }
        if trip.needsTimeZoneReview { beginEdit(tripID); return }
        switch item.item {
        case .event(let event):
            guard let current = trip.events.first(where: { $0.id == event.id }) else { return }
            beginEvent(dayID: current.startDayID, tripID: tripID, eventID: current.id)
        case .visit(let stop):
            openTodayVisit(stop.id, item: item, trip: trip, directions: directions)
        }
    }

    private func openTodayVisit(_ stopID: UUID, item: TripTodayItem, trip: TripPlan, directions: Bool) {
        guard let day = trip.days.first(where: { $0.stops.contains { $0.id == stopID } }),
              let current = day.stops.first(where: { $0.id == stopID }) else { return }
        if day.schedule?.clockIssue(on: trip.date(for: day), calendar: trip.calendar) != nil {
            beginDaySchedule(dayID: day.id, tripID: trip.id)
        } else if item.requiresTimeReview { beginStopTiming(stopID: stopID, dayID: day.id, tripID: trip.id) }
        else if directions, let showDirections = environment.showDirections { showDirections([current.place]) }
        else { environment.showPlace(current.place) }
    }
}

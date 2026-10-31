import Foundation
import TripDomain
import TripRouting
import TripLocalization

extension TripPlanningDraft {
    var title: String { isInsertion ? TripText.planningPlacement.text : TripText.planningPreview.text }
    var confirmationTitle: String { isInsertion ? TripText.addToDay.text : TripText.planningApply.text }
    var routeRequest: String { "\(revision)-\(routes.mode.rawValue)" }
    var mapPins: [TripPlanningMapPin] {
        day.stops.enumerated().compactMap { index, stop -> TripPlanningMapPin? in
            guard stop.place.coordinate.isValid else { return nil }
            return TripPlanningMapPin(stop: stop, number: index + 1)
        }
    }
    var missingLocations: Bool { mappedStops.count != day.stops.count }
    var timeIssue: String? {
        if trip.needsTimeZoneReview { return TripText.olderSchedulesNeedTheirOriginalTimeZoneConfirmedReview.text }
        if let issue = day.schedule?.clockIssue(on: trip.date(for: original), calendar: trip.calendar) { return issue }
        return day.schedule == nil ? TripText.planningNoSchedule.text : nil
    }
    var visits: [TripPlanningVisit] {
        let timeline = timeline
        let conflicts = Dictionary(grouping: conflicts, by: \.stopID)
        let allowances = routes.shortAllowances
        return day.stops.enumerated().map { index, stop in
            TripPlanningVisit(stop: stop, number: index + 1, entry: timeline?[stop.id],
                              bookings: conflicts[stop.id] ?? [], shortAllowance: allowances.contains(stop.id),
                              isNew: addedStopID == stop.id)
        }
    }

    func matches(_ current: TripPlan) -> Bool {
        current.days.first(where: { $0.id == original.id }) == original
            && current.events == trip.events && current.timeZoneID == trip.timeZoneID
            && current.localStartDate == trip.localStartDate && current.startDate == trip.startDate
            && day.stops.count <= TripLimits.stops
    }

    var placementOptions: [TripPlacementOption] {
        original.stops.enumerated().map { TripPlacementOption(id: $0.offset, title: $0.element.place.name) }
            + [TripPlacementOption(id: original.stops.count, title: TripText.planningEnd.text)]
    }

    func refreshRoutes() async { await routes.load(day.stops) }
}

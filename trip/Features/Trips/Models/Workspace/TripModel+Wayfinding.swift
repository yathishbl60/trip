import Foundation
import TripDomain
import TripLocalization

extension TripModel {
    func openSection(_ section: TripSection, tripID: UUID) {
        guard !hasEditingSession, let trip = library.trip(tripID) else { return }
        selectTrip(tripID)
        let route = section.destination.map { TripDetailRoute(tripID: tripID, destination: $0) }
        guard !TripDetailRoute.sameDestination(presentation.detailRoute, route) else { return }
        if section == .details { lookup.prepare(trip) }
        presentation.detailRoute = route
    }

    func openWorkspaceTool(_ tool: TripWorkspaceTool, tripID: UUID) {
        guard !hasEditingSession, library.trip(tripID) != nil else { return }
        switch tool {
        case .tripDetails: beginEdit(tripID)
        case .calendar: systemActions.showCalendar(tripID: tripID)
        case .reminders: systemActions.showReminders(tripID: tripID)
        }
    }

    func openDayTool(_ tool: TripDayTool, dayID: UUID, tripID: UUID) {
        guard !hasEditingSession, let trip = library.trip(tripID),
              trip.days.contains(where: { $0.id == dayID }) else { return }
        if tool == .schedule, trip.needsTimeZoneReview { beginEdit(tripID); return }
        switch tool {
        case .schedule: beginDaySchedule(dayID: dayID, tripID: tripID)
        case .planning: beginPlanning(dayID: dayID, tripID: tripID)
        case .weather: beginWeather(dayID: dayID, tripID: tripID)
        case .addPlaces: beginSavedPlaces(dayID: dayID, tripID: tripID)
        case .map: presentation.detailRoute = TripDetailRoute(tripID: tripID, dayID: dayID)
        case .directions: showDayDirections(dayID: dayID, tripID: tripID)
        case .stopOrder: beginStopOrder(dayID: dayID, tripID: tripID)
        }
    }

    func editSavedDetail(_ itemID: UUID, tripID: UUID) {
        guard !hasEditingSession, let trip = library.trip(tripID) else { return }
        if let event = trip.events.first(where: { $0.id == itemID }) {
            beginEvent(dayID: event.startDayID, tripID: tripID, eventID: itemID)
        } else if let day = trip.days.first(where: { $0.stops.contains { $0.id == itemID } }) {
            if trip.needsTimeZoneReview { beginEdit(tripID) }
            else { beginStopTiming(stopID: itemID, dayID: day.id, tripID: tripID) }
        } else { presentation.notice = TripText.thisSavedItemIsNoLongerAvailable.text }
    }

    func savedDetailPlace(_ itemID: UUID, tripID: UUID) -> Place? {
        library.trip(tripID)?.days.lazy.flatMap(\.stops).first { $0.id == itemID }?.place
    }
}

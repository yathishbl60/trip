#if DEBUG
import Foundation
import TripDomain

@MainActor enum PreviewSystemActions {
    static func model(_ kind: TripSystemActionSession.Kind) -> TripSystemActionsModel {
        let trip = plan()
        let library = TripLibraryModel(store: PreviewTripStore([trip]), loadedTrips: [trip])
        let model = TripSystemActionsModel(service: PreviewSystemActionProvider(), library: library)
        switch kind {
        case .calendar: model.showCalendar(tripID: trip.id)
        case .reminders: model.showReminders(tripID: trip.id)
        case .alarm: model.showAlarm(tripID: trip.id, eventID: trip.events[0].id)
        }
        return model
    }

    private static func plan() -> TripPlan {
        var trip = TripPlan(title: "Bangkok weekend")
        trip.timeZoneID = "Asia/Bangkok"
        var event = TripEvent(kind: .flight, title: "Flight to Bangkok", dayID: trip.days[0].id)
        let date = TripLocalDate(Date(timeIntervalSince1970: 2_000_000_000), calendar: trip.calendar)
        event.departureTime = TripZonedDateTime(date: date, minute: 600, zoneID: "Asia/Bangkok")
        event.arrivalTime = TripZonedDateTime(date: date, minute: 720, zoneID: "Asia/Bangkok")
        event.travelAllowanceMinutes = 120
        trip.events = [event]
        trip.checklist = [TripChecklistItem(title: "Travel adapter"), TripChecklistItem(title: "Check passport")]
        return trip
    }
}
#endif

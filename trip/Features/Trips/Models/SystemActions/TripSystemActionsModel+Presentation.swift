import Foundation
import TripDomain
import TripLocalization

extension TripSystemActionsModel {
    var canPerform: Bool {
        guard let session = presentation, !isWorking else { return false }
        switch session.kind {
        case .calendar, .reminders: return service.supportsCalendarReminders && !session.selectedIDs.isEmpty
        case .alarm: return service.supportsAlarms && session.booking?.start != nil && session.alarmDate > .now
        }
    }

    var title: String {
        switch presentation?.kind {
        case .calendar: TripText.exportToCalendar.text
        case .reminders: TripText.exportToReminders.text
        case .alarm: TripText.travelAlarm.text
        case nil: TripText.trip.text
        }
    }

    var actionTitle: String {
        presentation?.kind == .alarm ? TripText.setTravelAlarm.text : TripText.exportSelected.text
    }

    func summary(for booking: TripSystemBooking) -> String {
        guard let start = booking.start, let end = booking.end else { return TripText.reviewSystemActionTime.text }
        let format = Date.FormatStyle(date: .abbreviated, time: .shortened, timeZone: booking.timeZone)
        return "\(start.formatted(format)) – \(end.formatted(format))"
    }

    func select(_ id: String, included: Bool) {
        guard let session = presentation, !isWorking else { return }
        if included { session.selectedIDs.insert(id) }
        else { session.selectedIDs.remove(id) }
        session.result = nil
    }
}

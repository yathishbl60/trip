import Foundation
import TripLocalization

public nonisolated enum TripSystemActionError: LocalizedError {
    case unavailable, calendarDenied, remindersDenied, alarmsDenied, missingCalendar, invalidTime, changed, busy

    public var errorDescription: String? {
        switch self {
        case .unavailable: TripText.systemActionUnavailable.text
        case .calendarDenied: TripText.calendarAccessRequired.text
        case .remindersDenied: TripText.remindersAccessRequired.text
        case .alarmsDenied: TripText.alarmsAccessRequired.text
        case .missingCalendar: TripText.noWritableCalendar.text
        case .invalidTime: TripText.reviewSystemActionTime.text
        case .changed: TripText.systemActionSourceChanged.text
        case .busy: TripText.systemActionBusy.text
        }
    }
}

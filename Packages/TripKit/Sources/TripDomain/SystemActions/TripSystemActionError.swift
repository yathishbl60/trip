import Foundation
import TripLocalization

public nonisolated enum TripSystemActionError: LocalizedError, CustomLocalizedStringResourceConvertible {
    case unavailable, calendarDenied, remindersDenied, alarmsDenied, missingCalendar, invalidTime, changed, busy

    public var errorDescription: String? { String(localized: localizedStringResource) }

    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .unavailable: TripText.systemActionUnavailable.resource
        case .calendarDenied: TripText.calendarAccessRequired.resource
        case .remindersDenied: TripText.remindersAccessRequired.resource
        case .alarmsDenied: TripText.alarmsAccessRequired.resource
        case .missingCalendar: TripText.noWritableCalendar.resource
        case .invalidTime: TripText.reviewSystemActionTime.resource
        case .changed: TripText.systemActionSourceChanged.resource
        case .busy: TripText.systemActionBusy.resource
        }
    }
}

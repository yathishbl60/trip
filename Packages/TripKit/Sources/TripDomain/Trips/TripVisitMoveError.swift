import Foundation
#if !TRIP_STANDALONE
import TripLocalization
#endif

public nonisolated enum TripVisitMoveError: LocalizedError, CustomLocalizedStringResourceConvertible {
    case missingVisit, missingDay, duplicate, full, changed

    public var errorDescription: String? { String(localized: localizedStringResource) }

    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .missingVisit: TripText.siriTimingMissingVisit.resource
        case .missingDay: TripText.thisDayIsNoLongerAvailable.resource
        case .duplicate: TripText.siriMoveDuplicate.resource
        case .full: TripText.siriMoveFull.resource
        case .changed: TripText.siriMoveChanged.resource
        }
    }
}

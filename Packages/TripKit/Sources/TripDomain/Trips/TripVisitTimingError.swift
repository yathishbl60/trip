import Foundation
#if !TRIP_STANDALONE
import TripLocalization
#endif

public nonisolated enum TripVisitTimingError: LocalizedError, CustomLocalizedStringResourceConvertible {
    case missingVisit, emptyChange, invalidMinutes, invalidArrival, conflictingArrival, clockNeedsReview

    public var errorDescription: String? { String(localized: localizedStringResource) }

    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .missingVisit: TripText.siriTimingMissingVisit.resource
        case .emptyChange: TripText.siriTimingEmptyChange.resource
        case .invalidMinutes: TripText.siriTimingInvalidMinutes.resource
        case .invalidArrival: TripText.siriTimingInvalidArrival.resource
        case .conflictingArrival: TripText.siriTimingConflictingArrival.resource
        case .clockNeedsReview: TripText.siriTimingClockNeedsReview.resource
        }
    }
}

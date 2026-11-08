import Foundation
import TripLocalization

nonisolated enum TripCollectionIntentError: LocalizedError, CustomLocalizedStringResourceConvertible {
    case missingCollection, invalidTitle, ambiguousName, full, placesFull, notVisit

    var errorDescription: String? { String(localized: localizedStringResource) }

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .missingCollection: TripText.collectionMissing.resource
        case .invalidTitle: TripText.collectionInvalidTitle.resource
        case .ambiguousName: TripText.collectionAmbiguousName.resource
        case .full: TripText.collectionLimitReached.resource
        case .placesFull: TripText.collectionPlacesFull.resource
        case .notVisit: TripText.collectionNeedsSavedVisit.resource
        }
    }
}

#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import Foundation

nonisolated enum DirectionsSearchStatus: Equatable {
    case idle, noResults, unavailable, timedOut
    var canRetry: Bool { self == .unavailable || self == .timedOut }

    var title: String {
        switch self {
        case .idle: ""
        case .noResults: TripText.noPlacesFound.text
        case .unavailable: TripText.searchUnavailable.text
        case .timedOut: TripText.searchTimedOut.text
        }
    }

    var message: String {
        switch self {
        case .idle: ""
        case .noResults: TripText.tryAnotherNameOrAddress.text
        case .unavailable: TripText.chooseAPlaceFromTheListOrTryAgain.text
        case .timedOut: TripText.searchTookTooLongTryAgain.text
        }
    }
}
#endif

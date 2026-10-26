import TripLocalization
import Foundation

nonisolated struct TripPlaceSearchRequest: Hashable {
    let tripID: UUID
    let dayID: UUID
    let query: String

    init(tripID: UUID, dayID: UUID, text: String) throws {
        guard text.count <= 200 else { throw TripPlaceSearchIntentError.invalidText }
        let query = text.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
        guard !query.isEmpty else { throw TripPlaceSearchIntentError.invalidText }
        guard !query.contains("://"), !query.lowercased().hasPrefix("www.") else {
            throw TripPlaceSearchIntentError.linkInput
        }
        self.tripID = tripID
        self.dayID = dayID
        self.query = query
    }
}

nonisolated enum TripPlaceSearchIntentError: LocalizedError {
    case invalidText, linkInput, editing

    var errorDescription: String? {
        switch self {
        case .invalidText: TripText.enterOnePlaceNameOrAddressUpTo200.text
        case .linkInput: TripText.useAPlaceNameOrAddressInsteadOfA.text
        case .editing: TripText.finishOrCancelYourCurrentEditInTripThen2.text
        }
    }
}

import TripLocalization
import Foundation
import TripDomain

extension AppRuntime {
    static func openDetail(_ identity: TripDetailIdentity) async throws {
        let trip = try await trip(identity.tripID)
        guard identity.resolve(in: TripSurfacePlan(trip)) != nil else { throw TripDetailIntentError.missingDetail }
        guard activeScene?.trips.hasEditingSession != true else { throw TripDetailIntentError.editing }
        AppLaunchModel.shared.open(.savedDetail(identity))
    }
}

nonisolated enum TripDetailIntentError: LocalizedError, CustomLocalizedStringResourceConvertible {
    case missingDetail, editing
    var errorDescription: String? { String(localized: localizedStringResource) }

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .missingDetail: TripText.thisSavedDetailIsNoLongerAvailableOpenTrip.resource
        case .editing: TripText.finishOrCancelYourCurrentEditInTripThen.resource
        }
    }
}

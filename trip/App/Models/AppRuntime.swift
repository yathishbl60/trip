import TripLocalization
import TripDomain
import Foundation

/// Windows share durable data; each scene owns its navigation, map, and drafts.
@MainActor enum AppRuntime {
    static let savedTrips = makeLibrary()
    static let system = AppSystemModel()
    static weak var activeScene: AppModel?

    static func makeScene() -> AppModel {
        let trips = AppTripServices.makeTrips(library: savedTrips, tracking: TripTrackingModel(runtime: .shared))
        return AppModel(trips: trips, system: system)
    }

    private static func makeLibrary() -> TripLibraryModel {
        let library = AppTripServices.makeLibrary()
        library.onSaved = { plans in await system.publish(plans) }
        return library
    }

    static func library() async throws -> TripLibraryModel {
        await savedTrips.load()
        guard savedTrips.isReady else { throw TripIntentError.libraryUnavailable }
        return savedTrips
    }

    static func trip(_ id: UUID) async throws -> TripPlan {
        guard let trip = try await library().trip(id) else { throw TripIntentError.missingTrip }
        return trip
    }

    static func openTrip(_ id: UUID) {
        AppLaunchModel.shared.open(.savedTrip(id))
    }
}

nonisolated enum TripIntentError: LocalizedError {
    case libraryUnavailable, missingTrip, missingDay, invalidTitle, tooManyTrips, saveFailed, noPlaces

    var errorDescription: String? {
        switch self {
        case .libraryUnavailable: TripText.couldnTOpenSavedTripsOpenTripAndTry.text
        case .missingTrip: TripText.thisTripIsNoLongerAvailable.text
        case .missingDay: TripText.thisDayIsNoLongerAvailable.text
        case .invalidTitle: TripText.useATripNameWith1To80Characters.text
        case .tooManyTrips: TripText.yourTripLibraryIsFullDeleteATripTo.text
        case .saveFailed: TripText.couldnTSaveThisTripOpenTripAndTry.text
        case .noPlaces: TripText.savePlacesToThisTripBeforeCreatingADraft.text
        }
    }
}

import Foundation
import TripDomain
import TripLocalization

extension AppRuntime {
    static func markSavedVisit(_ detailID: String) async throws -> SavedTripDetailEntity {
        guard activeScene?.trips.hasEditingSession != true else { throw TripDetailIntentError.editing }
        let (plan, detail) = try await savedVisit(detailID)
        await savedTrips.flush()
        guard savedTrips.saveError == nil else { throw TripIntentError.saveFailed }
        let runtime = TripJourneyRuntime.shared
        try await runtime.advance(expectedStopID: detail.id, tripID: plan.id, dayID: detail.day.id)
        guard let journey = runtime.journey, journey.tripID == plan.id, journey.dayID == detail.day.id,
              journey.visited.contains(detail.id) else { throw TripSavedVisitError.notNext }
        let (current, result) = try await savedVisit(detailID)
        return SavedTripDetailEntity(result, plan: current)
    }

    static func directionsToSavedVisit(_ detailID: String) async throws -> URL {
        let (_, detail) = try await savedVisit(detailID)
        guard let stop = detail.day.stops.first(where: { $0.id == detail.id }), stop.coordinate.isValid,
              let url = TripSystemData.directionsURL(stop.coordinate) else { throw TripSavedVisitError.noLocation }
        return url
    }

    private static func savedVisit(_ detailID: String) async throws -> (TripSurfacePlan, TripDetailResult) {
        guard let identity = TripDetailIdentity(detailID) else { throw TripVisitTimingError.missingVisit }
        let plan = TripSurfacePlan(try await trip(identity.tripID))
        guard let result = identity.resolve(in: plan), result.day.stops.contains(where: { $0.id == result.id }) else {
            throw TripVisitTimingError.missingVisit
        }
        return (plan, result)
    }
}

nonisolated enum TripSavedVisitError: LocalizedError, CustomLocalizedStringResourceConvertible {
    case notNext, noLocation

    var errorDescription: String? { String(localized: localizedStringResource) }

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .notNext: TripText.siriVisitNotNext.resource
        case .noLocation: TripText.siriVisitNoLocation.resource
        }
    }
}

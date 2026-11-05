import TripDomain
import Foundation

extension AppRuntime {
    static func setVisitTiming(_ change: TripVisitTimingChange, detailID: String) async throws -> SavedTripDetailEntity {
        guard let identity = TripDetailIdentity(detailID) else { throw TripVisitTimingError.missingVisit }
        let library = try await library()
        guard activeScene?.trips.hasEditingSession != true else { throw TripDetailIntentError.editing }
        guard let original = library.trip(identity.tripID) else { throw TripIntentError.missingTrip }
        var updated = original
        if try change.apply(to: &updated, stopID: identity.itemID) {
            guard library.update(original.id, edit: { $0 = updated; return true }) else { throw TripIntentError.missingTrip }
        }
        await library.flush()
        guard library.saveError == nil else { throw TripIntentError.saveFailed }
        let current = try await trip(original.id)
        let plan = TripSurfacePlan(current)
        guard let detail = identity.resolve(in: plan) else { throw TripVisitTimingError.missingVisit }
        return SavedTripDetailEntity(detail, plan: plan)
    }
}

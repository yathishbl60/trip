import Foundation
import TripDomain

extension AppRuntime {
    static func moveSavedVisit(_ detailID: String, to dayNumber: Int) async throws -> SavedTripDetailEntity {
        guard let identity = TripDetailIdentity(detailID) else { throw TripVisitMoveError.missingVisit }
        let library = try await library()
        try Task.checkCancellation()
        guard activeScene?.trips.hasEditingSession != true else { throw TripDetailIntentError.editing }
        guard !TripJourneyRuntime.shared.isBusy else { throw TripJourneyError.busy }
        guard let original = library.trip(identity.tripID) else { throw TripIntentError.missingTrip }
        guard let day = original.days.first(where: { $0.number == dayNumber }) else { throw TripVisitMoveError.missingDay }
        var updated = original
        if try updated.moveVisit(identity.itemID, to: day.id) {
            guard library.update(original.id, edit: { $0 = updated; return true }) else { throw TripIntentError.missingTrip }
        }
        await library.flush()
        guard library.saveError == nil else { throw TripIntentError.saveFailed }
        return try movedVisitResult(identity, dayID: day.id, library: library)
    }

    private static func movedVisitResult(_ identity: TripDetailIdentity, dayID: UUID,
                                         library: TripLibraryModel) throws -> SavedTripDetailEntity {
        guard let current = library.trip(identity.tripID) else { throw TripIntentError.missingTrip }
        guard current.days.first(where: { $0.id == dayID })?.stops.contains(where: { $0.id == identity.itemID }) == true else {
            throw TripVisitMoveError.changed
        }
        let plan = TripSurfacePlan(current)
        guard let result = identity.resolve(in: plan) else { throw TripVisitMoveError.missingVisit }
        return SavedTripDetailEntity(result, plan: plan)
    }
}

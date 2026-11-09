import Foundation
import TripDomain

extension AppRuntime {
    static func scheduleCollectionPlace(_ value: String, on dayNumber: Int) async throws -> SavedTripDetailEntity {
        guard let identity = TripCollectionPlaceIdentity(value) else { throw TripCollectionSchedulingError.missingPlace }
        let library = try await editableCollectionLibrary()
        guard !TripJourneyRuntime.shared.isBusy else { throw TripJourneyError.busy }
        guard let original = library.trip(identity.collection.tripID) else { throw TripIntentError.missingTrip }
        guard let day = original.days.first(where: { $0.number == dayNumber }) else { throw TripVisitMoveError.missingDay }
        var updated = original
        let stopID = try TripCollectionScheduling.schedule(identity, on: day.id, in: &updated)
        if updated.days != original.days {
            guard library.update(original.id, edit: { $0 = updated; return true }) else { throw TripIntentError.missingTrip }
        }
        await library.flush()
        guard library.saveError == nil else { throw TripIntentError.saveFailed }
        return try scheduledCollectionResult(tripID: original.id, dayID: day.id, stopID: stopID, library: library)
    }

    private static func scheduledCollectionResult(tripID: UUID, dayID: UUID, stopID: UUID,
                                                   library: TripLibraryModel) throws -> SavedTripDetailEntity {
        guard let current = library.trip(tripID),
              current.days.first(where: { $0.id == dayID })?.stops.contains(where: { $0.id == stopID }) == true else {
            throw TripVisitMoveError.changed
        }
        let plan = TripSurfacePlan(current)
        guard let result = TripDetailIdentity(tripID: tripID, itemID: stopID).resolve(in: plan) else {
            throw TripCollectionSchedulingError.missingPlace
        }
        return SavedTripDetailEntity(result, plan: plan)
    }
}

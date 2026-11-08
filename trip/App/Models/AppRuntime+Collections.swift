import Foundation
import TripDomain
import TripLocalization

extension AppRuntime {
    static func editableCollectionLibrary() async throws -> TripLibraryModel {
        let library = try await library()
        try Task.checkCancellation()
        guard activeScene?.trips.hasEditingSession != true else { throw TripDetailIntentError.editing }
        return library
    }

    static func collection(_ identity: TripCollectionIdentity, library: TripLibraryModel) throws -> (TripPlan, TripCollection) {
        guard let plan = library.trip(identity.tripID), let collection = identity.resolve(in: plan) else {
            throw TripCollectionIntentError.missingCollection
        }
        return (plan, collection)
    }

    static func persistCollection(_ identity: TripCollectionIdentity, library: TripLibraryModel) async throws -> SavedTripCollectionEntity {
        await library.flush()
        guard library.saveError == nil else { throw TripIntentError.saveFailed }
        let (plan, collection) = try Self.collection(identity, library: library)
        return SavedTripCollectionEntity(collection, plan: plan)
    }

    static func readCollection(_ rawValue: String) async throws -> (text: String, spoken: String) {
        guard let identity = TripCollectionIdentity(rawValue) else { throw TripCollectionIntentError.missingCollection }
        let library = try await library()
        try Task.checkCancellation()
        let (plan, collection) = try Self.collection(identity, library: library)
        let names = collection.stops.prefix(TripLimits.stops).map { String($0.place.name.prefix(96)) }
        let header = "\(plan.title) · \(collection.title)"
        let text = ([header] + (names.isEmpty ? [TripText.noSavedPlaces.text] : names)).joined(separator: "\n")
        let spoken = ([collection.title, collection.summary] + Array(names.prefix(3))).joined(separator: ". ")
        return (text, spoken)
    }
}

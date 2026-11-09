import AppIntents
import Foundation
import TripDomain

nonisolated struct SavedTripCollectionPlaceQuery: EntityStringQuery, EnumerableEntityQuery {
    static var allowedExecutionTargets: IntentExecutionTargets { .main }

    @MainActor func allEntities() async throws -> [SavedTripCollectionPlaceEntity] {
        try await entities(matching: "")
    }

    @MainActor func entities(for identifiers: [String]) async throws -> [SavedTripCollectionPlaceEntity] {
        let plans = try await AppRuntime.library().trips
        let byID = Dictionary(plans.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return try identifiers.compactMap { value in
            try Task.checkCancellation()
            guard let identity = TripCollectionPlaceIdentity(value), let plan = byID[identity.collection.tripID],
                  let collection = identity.collection.resolve(in: plan), let stop = identity.resolve(in: plan) else { return nil }
            return SavedTripCollectionPlaceEntity(stop, collection: collection, plan: plan)
        }
    }

    @MainActor func entities(matching string: String) async throws -> [SavedTripCollectionPlaceEntity] {
        let plans = try await AppRuntime.library().trips
        let matches = try await TripCollectionPlaceSearch.find(in: plans, matching: string)
        return matches.map { SavedTripCollectionPlaceEntity($0.stop, collection: $0.collection, plan: $0.plan) }
    }

    @MainActor func suggestedEntities() async throws -> [SavedTripCollectionPlaceEntity] {
        try await allEntities()
    }
}

private nonisolated enum TripCollectionPlaceSearch {
    @concurrent static func find(in plans: [TripPlan], matching text: String) async throws -> [TripCollectionPlaceMatch] {
        let query = PlaceSearchQuery(String(text.prefix(200)))
        var matches: [TripCollectionPlaceMatch] = []
        for plan in plans {
            for collection in plan.collections {
                for stop in collection.stops {
                    try Task.checkCancellation()
                    guard query.matches([stop.place.name, collection.title, plan.title]) else { continue }
                    matches.append(TripCollectionPlaceMatch(stop: stop, collection: collection, plan: plan))
                }
            }
        }
        return matches
    }
}

private nonisolated struct TripCollectionPlaceMatch: Sendable {
    let stop: TripStop
    let collection: TripCollection
    let plan: TripPlan
}

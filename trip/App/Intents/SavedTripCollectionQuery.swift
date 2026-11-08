import AppIntents
import Foundation
import TripDomain

nonisolated struct SavedTripCollectionQuery: EntityStringQuery, EnumerableEntityQuery {
    static var allowedExecutionTargets: IntentExecutionTargets { .main }

    @MainActor func allEntities() async throws -> [SavedTripCollectionEntity] {
        let plans = try await AppRuntime.library().trips
        let matches = try await TripCollectionEntitySearch.find(in: plans)
        return matches.map { SavedTripCollectionEntity($0.collection, plan: $0.plan) }
    }

    @MainActor func entities(for identifiers: [String]) async throws -> [SavedTripCollectionEntity] {
        let plans = try await AppRuntime.library().trips
        let matches = try await TripCollectionEntitySearch.resolve(identifiers, in: plans)
        return matches.map { SavedTripCollectionEntity($0.collection, plan: $0.plan) }
    }

    @MainActor func entities(matching string: String) async throws -> [SavedTripCollectionEntity] {
        let plans = try await AppRuntime.library().trips
        let matches = try await TripCollectionEntitySearch.find(in: plans, matching: string)
        return matches.map { SavedTripCollectionEntity($0.collection, plan: $0.plan) }
    }

    @MainActor func suggestedEntities() async throws -> [SavedTripCollectionEntity] {
        try await allEntities()
    }
}

private nonisolated enum TripCollectionEntitySearch {
    @concurrent static func find(in plans: [TripPlan], matching text: String = "") async throws -> [TripCollectionMatch] {
        let query = PlaceSearchQuery(String(text.prefix(200)))
        var result: [TripCollectionMatch] = []
        for plan in plans {
            for collection in plan.collections {
                try Task.checkCancellation()
                let names = collection.stops.prefix(TripLimits.stops).map(\.place.name)
                guard query.matches([collection.title, plan.title] + names) else { continue }
                result.append(TripCollectionMatch(collection: collection, plan: plan))
            }
        }
        return result
    }

    @concurrent static func resolve(_ identifiers: [String], in plans: [TripPlan]) async throws -> [TripCollectionMatch] {
        let byID = Dictionary(plans.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return try identifiers.compactMap { rawValue in
            try Task.checkCancellation()
            guard let identity = TripCollectionIdentity(rawValue), let plan = byID[identity.tripID],
                  let collection = identity.resolve(in: plan) else { return nil }
            return TripCollectionMatch(collection: collection, plan: plan)
        }
    }
}

private nonisolated struct TripCollectionMatch: Sendable {
    let collection: TripCollection
    let plan: TripPlan
}

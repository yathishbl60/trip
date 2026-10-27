import AppIntents
import Foundation
import TripDomain

nonisolated struct SavedTripDetailQuery: EntityStringQuery {
    static var allowedExecutionTargets: IntentExecutionTargets { .main }

    @MainActor func entities(for identifiers: [String]) async throws -> [SavedTripDetailEntity] {
        guard !identifiers.isEmpty else { return [] }
        let trips = try await AppRuntime.library().trips
        let matches = try await TripDetailEntitySearch.resolve(identifiers, in: trips)
        return matches.map { SavedTripDetailEntity($0.result, plan: $0.plan) }
    }

    @MainActor func entities(matching string: String) async throws -> [SavedTripDetailEntity] {
        let trips = try await AppRuntime.library().trips
        let matches = try await TripDetailEntitySearch.find(in: trips, matching: string)
        return matches.map { SavedTripDetailEntity($0.result, plan: $0.plan) }
    }

    @MainActor func suggestedEntities() async throws -> [SavedTripDetailEntity] {
        let trips = try await AppRuntime.library().trips
        let upcoming = trips.filter { trip in
            guard let last = trip.days.last else { return false }
            return trip.date(for: last) >= trip.calendar.startOfDay(for: .now)
        }.sorted { $0.startDate < $1.startDate }
        let matches = try await TripDetailEntitySearch.find(in: Array(upcoming.prefix(10)), matching: "")
        return matches.map { SavedTripDetailEntity($0.result, plan: $0.plan) }
    }
}

private nonisolated enum TripDetailEntitySearch {
    @concurrent static func resolve(_ identifiers: [String], in trips: [TripPlan]) async throws -> [TripDetailMatch] {
        let tripsByID = Dictionary(trips.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var plans: [UUID: TripSurfacePlan] = [:]
        var matches: [TripDetailMatch] = []
        for value in identifiers {
            try Task.checkCancellation()
            guard let identity = TripDetailIdentity(value), let trip = tripsByID[identity.tripID] else { continue }
            let plan = plans[trip.id] ?? TripSurfacePlan(trip)
            plans[trip.id] = plan
            guard let result = identity.resolve(in: plan) else { continue }
            matches.append(TripDetailMatch(result: result, plan: plan))
        }
        return matches
    }

    @concurrent static func find(in trips: [TripPlan], matching string: String) async throws -> [TripDetailMatch] {
        let query = TripDetailQuery(searchText: String(string.prefix(80)))
        var matches: [TripDetailMatch] = []
        for trip in trips {
            try Task.checkCancellation()
            let plan = TripSurfacePlan(trip)
            let results = query.results(in: plan).prefix(20 - matches.count)
            matches += results.map { TripDetailMatch(result: $0, plan: plan) }
            if matches.count >= 20 { break }
        }
        return matches
    }
}

private nonisolated struct TripDetailMatch: Sendable {
    let result: TripDetailResult
    let plan: TripSurfacePlan
}

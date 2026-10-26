import AppIntents
import CoreSpotlight
import Foundation
import TripDomain

/// A bounded index of upcoming saved details; notes and checklist text stay private.
@MainActor enum TripDetailSpotlightIndex {
    static func publish(_ plans: [TripSurfacePlan], defaults: UserDefaults?, now: Date = .now) async throws {
        let entities = entities(in: plans, now: now)
        let previous = Set(defaults?.stringArray(forKey: "spotlightDetailIDs") ?? [])
        let current = Set(entities.map(\.id))
        try await CSSearchableIndex.default().deleteAppEntities(identifiedBy: Array(previous.subtracting(current)),
                                                               ofType: SavedTripDetailEntity.self)
        try await CSSearchableIndex.default().indexAppEntities(entities)
        defaults?.set(Array(current).sorted(), forKey: "spotlightDetailIDs")
    }

    private static func entities(in plans: [TripSurfacePlan], now: Date) -> [SavedTripDetailEntity] {
        var entities: [SavedTripDetailEntity] = []
        for plan in plans.sorted(by: { $0.startDate < $1.startDate }) {
            let days = plan.days.filter {
                $0.date >= $0.calendar.startOfDay(for: now)
            }
            let upcoming = TripSurfacePlan(id: plan.id, title: plan.title, startDate: plan.startDate, days: days)
            let results = TripDetailQuery().results(in: upcoming)
            entities += results.prefix(300 - entities.count).map { SavedTripDetailEntity($0, plan: upcoming) }
            if entities.count >= 300 { break }
        }
        return entities
    }
}

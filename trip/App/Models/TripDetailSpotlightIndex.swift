import AppIntents
import CoreSpotlight
import Foundation
import TripDomain

/// A bounded index of upcoming saved details; notes and checklist text stay private.
@MainActor enum TripDetailSpotlightIndex {
    static func publish(_ plans: [TripSurfacePlan], defaults: UserDefaults?, now: Date = .now,
                        isCurrent: () -> Bool) async throws {
        let details = try await AppSystemProjection.details(in: plans, now: now)
        try Task.checkCancellation()
        guard isCurrent() else { return }
        let entities = details.map { SavedTripDetailEntity($0.result, plan: $0.plan) }
        let previous = Set(defaults?.stringArray(forKey: "spotlightDetailIDs") ?? [])
        let current = Set(entities.map(\.id))
        try await CSSearchableIndex.default().deleteAppEntities(identifiedBy: Array(previous.subtracting(current)),
                                                               ofType: SavedTripDetailEntity.self)
        try await CSSearchableIndex.default().indexAppEntities(entities)
        defaults?.set(Array(current).sorted(), forKey: "spotlightDetailIDs")
    }

}

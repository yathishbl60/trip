import AppIntents
import CoreSpotlight
import TripDomain
import Foundation

@MainActor final class TripSpotlightModel {
    private var task: Task<Void, Never>?
    private var generation = 0
    private let defaults = UserDefaults(suiteName: TripSystemData.appGroup)

    func publish(_ plans: [TripSurfacePlan]) async {
        generation += 1
        let token = generation
        let previous = task
        task = Task {
            await previous?.value
            guard token == generation else { return }
            await update(plans)
        }
        await task?.value
    }

    private func update(_ plans: [TripSurfacePlan]) async {
        let entities = plans.map { SavedTripEntity(TripSurfaceSummary($0)) }
        let previous = Set((defaults?.stringArray(forKey: "spotlightTripIDs") ?? []).compactMap(UUID.init(uuidString:)))
        let current = Set(plans.map(\.id))
        do {
            for id in previous.subtracting(current) {
                let entity = EntityIdentifier(for: SavedTripEntity.self, identifier: id)
                try await IntentDonationManager.shared.deleteDonations(matching: .entityIdentifier(entity))
            }
            try await CSSearchableIndex.default().deleteAppEntities(identifiedBy: Array(previous.subtracting(current)),
                                                                   ofType: SavedTripEntity.self)
            try await CSSearchableIndex.default().indexAppEntities(entities)
            defaults?.set(current.map(\.uuidString), forKey: "spotlightTripIDs")
            try await TripDetailSpotlightIndex.publish(plans, defaults: defaults)
        } catch { /* Indexing is retried after the next durable library publication. */ }
    }
}

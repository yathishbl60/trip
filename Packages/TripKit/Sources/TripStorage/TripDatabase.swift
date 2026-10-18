import TripDomain
import Foundation
import SwiftData

@ModelActor actor TripDatabase {
    private var latestRevision = 0

    func load(legacyURL: URL?) throws -> [TripPlan] {
        try importLegacy(legacyURL)
        let request = FetchDescriptor<StoredTrip>(sortBy: [SortDescriptor(\.position)])
        return try modelContext.fetch(request).map { try $0.snapshot() }
    }

    func save(_ trips: [TripPlan], revision: Int, changedIDs: Set<UUID>?) throws {
        guard revision > latestRevision else { return }
        do {
            try replace(trips, changedIDs: changedIDs)
            try modelContext.save()
            latestRevision = revision
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    private func replace(_ trips: [TripPlan], changedIDs: Set<UUID>? = nil) throws {
        let existing = try modelContext.fetch(FetchDescriptor<StoredTrip>())
        let byID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
        var retained = Set<UUID>()
        for (position, plan) in trips.enumerated() {
            guard retained.insert(plan.id).inserted else { continue }
            if let record = byID[plan.id] {
                if changedIDs?.contains(plan.id) != false { try record.update(plan, position: position) }
                else if record.position != position { record.position = position }
            }
            else { modelContext.insert(try StoredTrip(plan: plan, position: position)) }
        }
        for record in existing where !retained.contains(record.id) { modelContext.delete(record) }
    }

    private func importLegacy(_ url: URL?) throws {
        guard try modelContext.fetchCount(FetchDescriptor<TripStorageMetadata>()) == 0 else { return }
        do {
            if let url, FileManager.default.fileExists(atPath: url.path),
               try modelContext.fetchCount(FetchDescriptor<StoredTrip>()) == 0 {
                let plans = try JSONDecoder().decode([TripPlan].self, from: Data(contentsOf: url))
                try replace(plans)
            }
            modelContext.insert(TripStorageMetadata(key: "legacy-import-complete"))
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}

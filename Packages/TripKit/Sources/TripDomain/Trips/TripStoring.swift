import Foundation

/// Persistent models stay behind this boundary; features exchange value snapshots.
public nonisolated protocol TripStoring: Sendable {
    func load() async throws -> [TripPlan]
    func save(_ trips: [TripPlan], revision: Int, changedIDs: Set<UUID>?) async throws
}

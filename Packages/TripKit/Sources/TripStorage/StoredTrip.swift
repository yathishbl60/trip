import TripDomain
import Foundation
import SwiftData

/// SwiftData owns durable records; views receive independent Sendable snapshots.
@Model nonisolated final class StoredTrip {
    @Attribute(.unique) var id: UUID
    var title: String
    var startDate: Date
    var position: Int
    var payload: Data

    init(plan: TripPlan, position: Int) throws {
        id = plan.id
        title = plan.title
        startDate = plan.startDate
        self.position = position
        payload = try JSONEncoder().encode(plan)
    }

    func update(_ plan: TripPlan, position: Int) throws {
        let data = try JSONEncoder().encode(plan)
        if payload != data { payload = data }
        if title != plan.title { title = plan.title }
        if startDate != plan.startDate { startDate = plan.startDate }
        if self.position != position { self.position = position }
    }

    func snapshot() throws -> TripPlan { try JSONDecoder().decode(TripPlan.self, from: payload) }
}

@Model nonisolated final class TripStorageMetadata {
    @Attribute(.unique) var key: String
    init(key: String) { self.key = key }
}

nonisolated enum TripSchema: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [StoredTrip.self, TripStorageMetadata.self] }
}

nonisolated enum TripMigration: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [TripSchema.self] }
    static var stages: [MigrationStage] { [] }
}

import TripDomain
import Foundation
import SwiftData

public actor TripStore: TripStoring {
    private let customURL: URL?
    private let inMemory: Bool
    private var database: TripDatabase?

    public init(url: URL? = nil, inMemory: Bool = false) {
        customURL = url
        self.inMemory = inMemory
    }

    public func load() async throws -> [TripPlan] {
        let database = try databaseInstance()
        return try await database.load(legacyURL: inMemory || customURL != nil ? nil : legacyURL)
    }

    public func save(_ trips: [TripPlan], revision: Int, changedIDs: Set<UUID>?) async throws {
        try await databaseInstance().save(trips, revision: revision, changedIDs: changedIDs)
    }

    private var legacyURL: URL? {
        try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask,
                                    appropriateFor: nil, create: true).appending(path: "trips.json")
    }

    private func databaseInstance() throws -> TripDatabase {
        if let database { return database }
        let schema = Schema(versionedSchema: TripSchema.self)
        let configuration = customURL.map {
            ModelConfiguration(schema: schema, url: $0, cloudKitDatabase: .none)
        } ?? ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, migrationPlan: TripMigration.self,
                                           configurations: [configuration])
        let database = TripDatabase(modelContainer: container)
        self.database = database
        return database
    }
}

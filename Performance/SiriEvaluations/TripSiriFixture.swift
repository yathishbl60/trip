import Foundation
import SiriEvaluations
import Testing

enum TripSiriFixture {
    static let name = "Siri Review"
    static var identifier: String { ProcessInfo.processInfo.environment["TRIP_SIRI_TRIP_ID"] ?? "" }

    static func validate() async throws {
        let id = try #require(UUID(uuidString: identifier), "Set TRIP_SIRI_TRIP_ID to the staged trip UUID.")
        let entities = try await TripSiriDefinitions.trip.entities(identifiers: [id])
        try #require(entities.count == 1, "The staged trip must exist on the device.")
        let actualName: String = try entities[0].name
        try #require(actualName == name, "Use the dedicated Siri Review fixture, not a personal trip.")
    }

    static func showTrip() async throws {
        let entity = TripSiriDefinitions.trip.makeReference(identifier: identifier)
        try await TripSiriDefinitions.openTrip.makeIntent(target: entity).run()
    }
}

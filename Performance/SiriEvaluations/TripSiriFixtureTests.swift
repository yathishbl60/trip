import SiriEvaluations
import Testing

@Suite("Trip Siri fixture", .serialized)
struct TripSiriFixtureTests {
    @Test("Inspect the dedicated fixture UUID")
    func fixtureIdentifier() async throws {
        let matches = try await TripSiriDefinitions.trip.entities(matching: TripSiriFixture.name)
        let exact = try matches.filter { entity in
            let name: String = try entity.name
            return name == TripSiriFixture.name
        }
        try #require(exact.count == 1, "Create exactly one saved trip named Siri Review before evaluation.")
        Attachment.record(exact[0].identifier.instanceIdentifier, named: "TRIP_SIRI_TRIP_ID")
    }
}

#if os(iOS)
import Foundation
import Testing
import TripDomain
@testable import trip

struct TripActivityPayloadTests {
    @Test func unicodeAndEscapesStayWithinTheCombinedActivityBudget() throws {
        let text = String(repeating: "👩🏽‍👩🏽‍👧🏽‍👦🏽\n\"\\", count: 96)
        let first = TripSurfaceStop(id: UUID(), name: text, category: .museum, coordinate: .bangkok)
        let second = TripSurfaceStop(id: UUID(), name: text, category: .park, coordinate: .bangkok)
        let day = TripSurfaceDay(id: UUID(), number: 30, date: .now, stops: [first, second], zoneID: "Asia/Bangkok")
        let journey = TripJourney(tripID: UUID(), dayID: day.id)
        let attributes = TripActivityAttributes(tripID: journey.tripID, dayID: day.id,
            tripTitle: TripActivityAttributes.boundedText(text), dayNumber: day.number)
        let state = TripActivityAttributes.ContentState(journey: journey, day: day, title: text)
        let size = try JSONEncoder().encode(attributes).count + JSONEncoder().encode(state).count
        #expect(size < 4_096 && state.nextStopID == first.id && state.nextCoordinate == first.coordinate)
        #expect(!state.nextStopName.isEmpty && !attributes.tripTitle.isEmpty)
    }

    @Test func oversizedSingleCharacterStillProducesAVisibleLabel() throws {
        let text = "a" + String(repeating: "\u{0301}", count: 2_000)
        let result = TripActivityAttributes.boundedText(text)
        #expect(!result.isEmpty)
        #expect(try JSONEncoder().encode(result).count <= 384)
        #expect(TripActivityAttributes.boundedText("Lumphini Park") == "Lumphini Park")
    }
}
#endif

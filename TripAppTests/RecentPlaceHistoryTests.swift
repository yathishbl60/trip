import Foundation
import Testing
import TripDomain
import TripStorage
@testable import trip

@MainActor struct RecentPlaceHistoryTests {
    @Test func historyIsBoundedDeduplicatedAndIgnoresEmptySearches() {
        var history = RecentPlaceHistory()
        for index in 0..<20 { history.record(.search("Place \(index)")) }
        history.record(.search("  PLACE   19 "))
        history.record(.search("   "))
        #expect(history.entries.count == 12)
        #expect(history.entries.first == .search("PLACE 19"))
        #expect(Set(history.entries.map(\.id)).count == 12)
    }

    @Test func olderWritesCannotRestoreClearedHistory() async throws {
        let url = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString + ".json")
        let store = RecentPlaceStore(url: url)
        var history = RecentPlaceHistory()
        history.record(.search("Museum"))
        try await store.save(history, revision: 1)
        #expect(try await store.load().entries.count == 1)
        try await store.save(RecentPlaceHistory(), revision: 3)
        try await store.save(history, revision: 2)
        #expect(try await store.load().entries.isEmpty)
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test func legacySavedPlacesDecodeWithoutAnAppleIdentifier() throws {
        let place = MapRefinementFixtures.place("Museum")
        let data = try JSONEncoder().encode(place)
        var json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        json.removeValue(forKey: "mapItemIdentifier")
        let legacy = try JSONSerialization.data(withJSONObject: json)
        let decoded = try JSONDecoder().decode(Place.self, from: legacy)
        #expect(decoded == place && decoded.mapItemIdentifier == nil)
    }
}

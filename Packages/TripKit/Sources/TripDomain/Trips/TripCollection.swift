#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

public nonisolated struct TripCollection: Codable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var stops: [TripStop] = []

    public init(title: String) {
        id = UUID()
        self.title = title
    }

    public var summary: String { TripText.placeCount(stops.count).text }
}

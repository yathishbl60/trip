import Foundation

public nonisolated struct TripReminderExport: Equatable, Identifiable, Sendable {
    public let tripID: UUID
    public let itemID: UUID
    public let title: String
    public var id: String { "\(tripID.uuidString):\(itemID.uuidString)" }

    public init(tripID: UUID, item: TripChecklistItem) {
        self.tripID = tripID
        itemID = item.id
        title = item.title
    }

    public var deepLink: URL {
        var components = URLComponents()
        components.scheme = "trip"
        components.host = "trip"
        components.path = "/\(tripID.uuidString)"
        components.queryItems = [URLQueryItem(name: "surface", value: "checklist")]
        return components.url ?? URL(filePath: "/")
    }
}

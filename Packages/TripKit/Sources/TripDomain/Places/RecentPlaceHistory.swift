import Foundation

public nonisolated enum RecentPlaceEntry: Codable, Equatable, Identifiable, Sendable {
    case search(String)
    case place(Place)

    public var id: String {
        switch self {
        case .search(let query): "search:" + query.folding(options: [.caseInsensitive, .diacriticInsensitive],
                                                         locale: Locale(identifier: "en_US_POSIX"))
        case .place(let place): "place:" + place.id
        }
    }
}

public nonisolated struct RecentPlaceHistory: Codable, Equatable, Sendable {
    public private(set) var entries: [RecentPlaceEntry] = []
    public init() {}

    public mutating func record(_ entry: RecentPlaceEntry) {
        let entry: RecentPlaceEntry = switch entry {
        case .search(let query): .search(String(PlaceSearchQuery(query).text.prefix(120)))
        case .place(let place): .place(place)
        }
        if case .search(let query) = entry, query.isEmpty { return }
        if case .place(let place) = entry, !place.coordinate.isValid { return }
        entries.removeAll { $0.id == entry.id }
        entries.insert(entry, at: 0)
        entries = Array(entries.prefix(12))
    }
}

public nonisolated protocol RecentPlaceStoring: Sendable {
    func load() async throws -> RecentPlaceHistory
    func save(_ history: RecentPlaceHistory, revision: Int) async throws
}

public actor MemoryRecentPlaceStore: RecentPlaceStoring {
    private var history = RecentPlaceHistory()
    private var revision = -1
    public init() {}
    public func load() -> RecentPlaceHistory { history }
    public func save(_ history: RecentPlaceHistory, revision: Int) {
        guard revision >= self.revision else { return }
        self.history = history
        self.revision = revision
    }
}

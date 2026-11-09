import Foundation
import TripDomain

/// Local convenience history, separate from saved trips and shared system surfaces.
public actor RecentPlaceStore: RecentPlaceStoring {
    private let customURL: URL?
    private var revision = -1

    public init(url: URL? = nil) { customURL = url }

    public func load() throws -> RecentPlaceHistory {
        let url = try fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return RecentPlaceHistory() }
        let decoded = try JSONDecoder().decode(RecentPlaceHistory.self, from: Data(contentsOf: url))
        var bounded = RecentPlaceHistory()
        for entry in decoded.entries.prefix(12).reversed() { bounded.record(entry) }
        return bounded
    }

    public func save(_ history: RecentPlaceHistory, revision: Int) throws {
        guard revision >= self.revision else { return }
        let url = try fileURL()
        if history.entries.isEmpty {
            if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
        } else {
            try JSONEncoder().encode(history).write(to: url, options: .atomic)
        }
        self.revision = revision
    }

    private func fileURL() throws -> URL {
        if let customURL { return customURL }
        return try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask,
                                           appropriateFor: nil, create: true).appending(path: "recent-places.json")
    }
}

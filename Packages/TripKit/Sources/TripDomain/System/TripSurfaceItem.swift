#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

/// A bounded itinerary detail that excludes private notes.
public nonisolated struct TripSurfaceItem: Codable, Equatable, Sendable, Identifiable {
    public let id: UUID
    public let title: String
    public let symbol: String
    public let kind: TripEventKind?
    public let detail: String
    public let startsAt: Date?
    public let endsAt: Date?
    public let startZoneID: String?
    public let endZoneID: String?
    public var requiresTimeReview: Bool? = nil

    public init(id: UUID, title: String, symbol: String, kind: TripEventKind? = nil,
                detail: String = "", startsAt: Date? = nil, endsAt: Date? = nil,
                startZoneID: String? = nil, endZoneID: String? = nil) {
        self.id = id
        self.title = String(title.prefix(96))
        self.symbol = symbol
        self.kind = kind
        self.detail = String(detail.prefix(200))
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.startZoneID = startZoneID
        self.endZoneID = endZoneID
    }

    public init(_ stop: TripSurfaceStop) {
        self.init(id: stop.id, title: stop.name, symbol: stop.category.symbol)
    }

    public var timeText: String {
        if requiresTimeReview == true { return TripText.reviewTimeZone.text }
        if let startZoneID {
            let start = startsAt.map { zonedText($0, zoneID: startZoneID) }
            let end = endsAt.map { zonedText($0, zoneID: endZoneID ?? startZoneID) }
            let text = [start, end].compactMap { $0 }.joined(separator: " → ")
            return text.isEmpty ? TripText.timeNotSet.text : text
        }
        guard let startsAt else {
            return endsAt.map { TripText.endsValue($0.formatted(date: .abbreviated, time: .shortened)).text } ?? TripText.timeNotSet.text
        }
        let spansDays = endsAt.map { !Calendar.current.isDate(startsAt, inSameDayAs: $0) } ?? false
        let start = startsAt.formatted(date: spansDays ? .abbreviated : .omitted, time: .shortened)
        guard let endsAt else { return start }
        let style: Date.FormatStyle.DateStyle = Calendar.current.isDate(startsAt, inSameDayAs: endsAt)
            ? .omitted : .abbreviated
        return "\(start) – \(endsAt.formatted(date: style, time: .shortened))"
    }

    private func zonedText(_ date: Date, zoneID: String) -> String {
        let zone = TimeZone(identifier: zoneID) ?? TimeZone(secondsFromGMT: 0)!
        return "\(date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened, timeZone: zone))) · \(zoneID)"
    }
}

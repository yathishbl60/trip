#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

public nonisolated struct TripPlan: Codable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var days: [TripDay]
    public var collections: [TripCollection] = []
    public var checklist: [TripChecklistItem] = []
    public var events: [TripEvent] = []
    public let createdAt: Date
    public var startDate: Date {
        didSet { if timeZoneID != nil { localStartDate = TripLocalDate(startDate, calendar: calendar) } }
    }
    public var timeZoneID: String? = nil
    public var localStartDate: TripLocalDate? = nil
    public var notes = ""

    public init(title: String) {
        id = UUID()
        self.title = title
        days = [TripDay(number: 1)]
        createdAt = .now
        startDate = .now
        timeZoneID = TimeZone.current.identifier
        localStartDate = TripLocalDate(startDate, calendar: calendar)
    }

    public init(copying source: TripPlan) {
        id = UUID()
        let suffix = TripText.valueCopy("").text
        title = TripText.valueCopy(String(source.title.prefix(max(0, TripLimits.titleCharacters - suffix.count)))).text
        days = source.days
        collections = source.collections
        checklist = source.checklist.map { TripChecklistItem(title: $0.title) }
        events = source.events
        createdAt = .now
        startDate = source.startDate
        timeZoneID = source.timeZoneID
        localStartDate = source.localStartDate
        notes = source.notes
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, days, collections, checklist, events, createdAt, startDate, notes, timeZoneID, localStartDate
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        days = try values.decode([TripDay].self, forKey: .days)
        collections = try values.decodeIfPresent([TripCollection].self, forKey: .collections) ?? []
        checklist = try values.decodeIfPresent([TripChecklistItem].self, forKey: .checklist) ?? []
        events = try values.decodeIfPresent([TripEvent].self, forKey: .events) ?? []
        createdAt = try values.decode(Date.self, forKey: .createdAt)
        startDate = try values.decode(Date.self, forKey: .startDate)
        notes = try values.decodeIfPresent(String.self, forKey: .notes) ?? ""
        timeZoneID = try values.decodeIfPresent(String.self, forKey: .timeZoneID)
        localStartDate = try values.decodeIfPresent(TripLocalDate.self, forKey: .localStartDate)
    }

    public var stopCount: Int { days.reduce(0) { $0 + $1.stops.count } }
    public var savedPlaces: [Place] {
        var seen: Set<String> = []
        let stops = days.flatMap(\.stops) + collections.flatMap(\.stops)
        return stops.compactMap { seen.insert($0.place.id).inserted ? $0.place : nil }
    }

    public var summary: String {
        let stops = TripText.placeCount(stopCount).text
        let duration = TripText.dayCount(days.count).text
        let eventText = TripText.eventCount(events.count).text
        return events.isEmpty ? "\(duration) · \(stops)" : "\(duration) · \(stops) · \(eventText)"
    }

    public func date(for day: TripDay) -> Date {
        let base = localStartDate?.noon(in: calendar).map { calendar.startOfDay(for: $0) } ?? startDate
        return calendar.date(byAdding: .day, value: day.number - 1, to: base) ?? base
    }
}

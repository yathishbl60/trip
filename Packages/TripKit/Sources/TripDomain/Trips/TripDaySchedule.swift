import Foundation

/// Local wall-clock minutes. End times at or before the start fall on the next day.
public nonisolated struct TripDaySchedule: Codable, Equatable, Sendable {
    public var startMinute: Int
    public var endMinute: Int
    public var startOccurrence: TripClockOccurrence
    public var endOccurrence: TripClockOccurrence

    public init(startMinute: Int = 540, endMinute: Int = 1080,
                startOccurrence: TripClockOccurrence = .unresolved, endOccurrence: TripClockOccurrence = .unresolved) {
        self.startMinute = min(max(startMinute, 0), 1439)
        self.endMinute = min(max(endMinute, 0), 1439)
        self.startOccurrence = startOccurrence
        self.endOccurrence = endOccurrence
    }

    public var normalized: Self {
        Self(startMinute: startMinute, endMinute: endMinute, startOccurrence: startOccurrence, endOccurrence: endOccurrence)
    }
    public var endsNextDay: Bool { normalized.endMinute <= normalized.startMinute }

    private enum CodingKeys: String, CodingKey { case startMinute, endMinute, startOccurrence, endOccurrence }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(startMinute: try values.decodeIfPresent(Int.self, forKey: .startMinute) ?? 540,
                  endMinute: try values.decodeIfPresent(Int.self, forKey: .endMinute) ?? 1080,
                  startOccurrence: try values.decodeIfPresent(TripClockOccurrence.self, forKey: .startOccurrence) ?? .unresolved,
                  endOccurrence: try values.decodeIfPresent(TripClockOccurrence.self, forKey: .endOccurrence) ?? .unresolved)
    }
}

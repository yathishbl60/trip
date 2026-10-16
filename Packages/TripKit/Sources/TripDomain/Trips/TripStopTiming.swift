import Foundation

/// Travel and buffer are user-entered allowances before this stop, not route estimates.
public nonisolated struct TripStopTiming: Codable, Equatable, Sendable {
    public var arrivalMinute: Int?
    public var visitMinutes: Int
    public var travelMinutes: Int
    public var bufferMinutes: Int
    public var arrivalOccurrence: TripClockOccurrence

    public init(arrivalMinute: Int? = nil, visitMinutes: Int = 60,
                travelMinutes: Int = 15, bufferMinutes: Int = 10, arrivalOccurrence: TripClockOccurrence = .unresolved) {
        self.arrivalMinute = arrivalMinute.map { min(max($0, 0), 2879) }
        self.visitMinutes = min(max(visitMinutes, TripLimits.visitMinutes.lowerBound), TripLimits.visitMinutes.upperBound)
        self.travelMinutes = min(max(travelMinutes, 0), TripLimits.travelMinutes.upperBound)
        self.bufferMinutes = min(max(bufferMinutes, 0), TripLimits.bufferMinutes.upperBound)
        self.arrivalOccurrence = arrivalOccurrence
    }

    public var normalized: Self {
        Self(arrivalMinute: arrivalMinute, visitMinutes: visitMinutes,
             travelMinutes: travelMinutes, bufferMinutes: bufferMinutes, arrivalOccurrence: arrivalOccurrence)
    }

    public var unpinned: Self {
        var copy = normalized
        copy.arrivalMinute = nil
        return copy
    }

    public func arrivalClock(on date: Date, calendar: Calendar) -> TripZonedDateTime? {
        guard let minute = arrivalMinute,
              let day = calendar.date(byAdding: .day, value: minute / 1440, to: date) else { return nil }
        var clock = TripZonedDateTime(date: TripLocalDate(day, calendar: calendar), minute: minute % 1440,
                                      zoneID: calendar.timeZone.identifier)
        clock.occurrence = arrivalOccurrence
        return clock
    }

    private enum CodingKeys: String, CodingKey { case arrivalMinute, visitMinutes, travelMinutes, bufferMinutes, arrivalOccurrence }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(arrivalMinute: try values.decodeIfPresent(Int.self, forKey: .arrivalMinute),
                  visitMinutes: try values.decodeIfPresent(Int.self, forKey: .visitMinutes) ?? 60,
                  travelMinutes: try values.decodeIfPresent(Int.self, forKey: .travelMinutes) ?? 15,
                  bufferMinutes: try values.decodeIfPresent(Int.self, forKey: .bufferMinutes) ?? 10,
                  arrivalOccurrence: try values.decodeIfPresent(TripClockOccurrence.self, forKey: .arrivalOccurrence) ?? .unresolved)
    }
}

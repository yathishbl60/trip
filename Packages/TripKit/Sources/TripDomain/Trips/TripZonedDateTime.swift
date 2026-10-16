#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

/// Civil time and zone are preserved; ambiguous clock changes require a choice.
public nonisolated struct TripZonedDateTime: Codable, Equatable, Sendable {
    public var date: TripLocalDate
    public var minute: Int
    public var zoneID: String
    public var occurrence = TripClockOccurrence.unresolved

    public init(date: TripLocalDate, minute: Int, zoneID: String) {
        self.date = date
        self.minute = minute
        self.zoneID = zoneID
    }

    public var calendar: Calendar { TripLocalDate.calendar(zoneID: zoneID) }
    public var candidates: [Date] {
        guard TimeZone(identifier: zoneID) != nil, (0..<1440).contains(minute),
              date.noon(in: calendar) != nil else { return [] }
        let components = DateComponents(year: date.year, month: date.month, day: date.day,
                                         hour: minute / 60, minute: minute % 60, second: 0)
        guard let civil = TripLocalDate.calendar(zoneID: "Etc/UTC").date(from: components) else { return [] }
        let offsets = Set(stride(from: -48, through: 48, by: 6).map {
            calendar.timeZone.secondsFromGMT(for: civil.addingTimeInterval(Double($0) * 3600))
        })
        return offsets.map { civil.addingTimeInterval(-Double($0)) }.filter(matches).sorted()
    }

    private func matches(_ instant: Date) -> Bool {
        TripLocalDate(instant, calendar: calendar) == date && TripScheduleClock.minute(of: instant, calendar: calendar) == minute
    }
    public var instant: Date? {
        let matches = candidates
        guard matches.count > 1 else { return matches.first }
        switch occurrence {
        case .unresolved: return nil
        case .first: return matches.first
        case .last: return matches.last
        }
    }
    public var issue: String? {
        if candidates.isEmpty { return TripText.thisLocalTimeDoesnTExistInThisTime.text }
        return instant == nil ? TripText.thisTimeOccursTwiceChooseTheFirstOrSecond.text : nil
    }
}

public nonisolated enum TripClockOccurrence: String, Codable, CaseIterable, Sendable {
    case unresolved, first, last
}

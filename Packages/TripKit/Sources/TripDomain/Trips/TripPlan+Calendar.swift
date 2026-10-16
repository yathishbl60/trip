import Foundation

extension TripPlan {
    public nonisolated var calendar: Calendar {
        TripLocalDate.calendar(zoneID: timeZoneID ?? TimeZone.current.identifier)
    }
    public nonisolated var needsTimeZoneReview: Bool {
        timeZoneID.flatMap(TimeZone.init(identifier:)) == nil || localStartDate == nil
    }

    public nonisolated func dateText(for day: TripDay) -> String {
        date(for: day).formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, timeZone: calendar.timeZone))
    }

    public nonisolated mutating func reviewTimeZone(_ zoneID: String, departure: TripLocalDate) -> Bool {
        guard TimeZone(identifier: zoneID) != nil,
              let base = departure.noon(in: TripLocalDate.calendar(zoneID: zoneID)) else { return false }
        timeZoneID = zoneID
        startDate = calendar.startOfDay(for: base)
        localStartDate = departure
        let snapshot = self
        for index in events.indices { events[index].reviewLegacyTimes(in: snapshot) }
        return true
    }
}

import Foundation

public nonisolated enum TripScheduleClock {
    public static func date(minute: Int, on day: Date, calendar: Calendar = .current) -> Date {
        let value = min(max(minute, 0), 2879)
        let base = calendar.date(byAdding: .day, value: value / 1440, to: calendar.startOfDay(for: day)) ?? day
        return calendar.date(bySettingHour: value % 1440 / 60, minute: value % 60, second: 0,
                             of: base, matchingPolicy: .nextTime, repeatedTimePolicy: .first) ?? base
    }

    public static func minute(of date: Date, calendar: Calendar = .current) -> Int {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }

    public static func offset(of date: Date, from day: Date, calendar: Calendar = .current) -> Int {
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: day),
                                           to: calendar.startOfDay(for: date)).day ?? 0
        return min(max(days, 0), 1) * 1440 + minute(of: date, calendar: calendar)
    }
}

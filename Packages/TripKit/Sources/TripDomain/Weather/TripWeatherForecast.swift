import Foundation

public nonisolated struct TripWeatherForecast: Sendable {
    public let hours: [TripWeatherHour]
    public let issuedAt: Date
    public let expiresAt: Date
    public let attribution: TripWeatherAttribution

    public var coverage: DateInterval? {
        guard let start = hours.map(\.date).min(), let last = hours.map(\.date).max() else { return nil }
        return DateInterval(start: start, end: last.addingTimeInterval(TripWeatherHour.duration))
    }

    public init(hours: [TripWeatherHour], issuedAt: Date, expiresAt: Date, attribution: TripWeatherAttribution) {
        self.hours = hours
        self.issuedAt = issuedAt
        self.expiresAt = expiresAt
        self.attribution = attribution
    }

    public func hour(containing date: Date) -> TripWeatherHour? {
        hours.first { $0.date <= date && date < $0.date.addingTimeInterval(TripWeatherHour.duration) }
    }
}

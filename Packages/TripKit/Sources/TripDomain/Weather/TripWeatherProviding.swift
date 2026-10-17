import Foundation

public nonisolated protocol TripWeatherProviding: Sendable {
    var availabilityIssue: String? { get }
    func forecast(at coordinate: Coordinate, during interval: DateInterval) async throws -> TripWeatherForecast
}

public nonisolated extension TripWeatherProviding {
    var availabilityIssue: String? { nil }
}

public nonisolated struct TripWeatherAttribution: Sendable {
    public let legalURL: URL
    public let lightMarkURL: URL?
    public let darkMarkURL: URL?

    public init(legalURL: URL, lightMarkURL: URL?, darkMarkURL: URL?) {
        self.legalURL = legalURL
        self.lightMarkURL = lightMarkURL
        self.darkMarkURL = darkMarkURL
    }
}

public nonisolated enum TripWeatherFailure: Error {
    case unavailable, configurationUnavailable, timedOut, invalidLocation, outsideForecastWindow
}

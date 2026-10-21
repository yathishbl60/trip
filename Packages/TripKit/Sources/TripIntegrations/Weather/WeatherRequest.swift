import CoreLocation
import Foundation
import TripDomain
import WeatherKit

nonisolated enum WeatherRequest {
    private static let deadline = Duration.seconds(12)
    private static let maximumCacheAge: TimeInterval = 10 * 60
    private static let hourLimit = 240

    static func fetch(_ coordinate: Coordinate) async throws -> TripWeatherForecast {
        try await withThrowingTaskGroup(of: TripWeatherForecast.self) { group in
            group.addTask { try await load(coordinate) }
            group.addTask {
                try await Task.sleep(for: deadline)
                throw TripWeatherFailure.timedOut
            }
            defer { group.cancelAll() }
            guard let result = try await group.next() else { throw CancellationError() }
            return result
        }
    }

    private static func load(_ coordinate: Coordinate) async throws -> TripWeatherForecast {
        let service = WeatherService.shared
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let hourly = try await service.weather(for: location, including: .hourly)
        try Task.checkCancellation()
        let attribution = try await service.attribution
        let source = TripWeatherAttribution(legalURL: attribution.legalPageURL,
                                            lightMarkURL: attribution.combinedMarkLightURL,
                                            darkMarkURL: attribution.combinedMarkDarkURL)
        let hours = hourly.prefix(hourLimit).map(makeHour)
        return TripWeatherForecast(hours: hours, issuedAt: hourly.metadata.date,
                                   expiresAt: min(hourly.metadata.expirationDate, .now.addingTimeInterval(maximumCacheAge)),
                                   attribution: source)
    }

    private static func makeHour(_ hour: HourWeather) -> TripWeatherHour {
        TripWeatherHour(date: hour.date, symbol: hour.symbolName,
                        temperatureCelsius: hour.temperature.converted(to: .celsius).value,
                        apparentCelsius: hour.apparentTemperature.converted(to: .celsius).value,
                        precipitationChance: hour.precipitationChance,
                        windKilometersPerHour: hour.wind.speed.converted(to: .kilometersPerHour).value)
    }
}

import CoreLocation
import Foundation
import TripDomain
import WeatherKit

/// Shared bounded cache. Only coordinates reach Apple Weather; trip titles and notes stay local.
public actor AppleTripWeatherService: TripWeatherProviding {
    private var cache: [Coordinate: TripWeatherForecast] = [:]
    private var pending: [Coordinate: Task<TripWeatherForecast, Error>] = [:]
    private let cacheLimit = 32
    private let concurrentLocationLimit = 4
    private let forecastHorizon: TimeInterval = 10 * 24 * 60 * 60

    public init() {}

    public func forecast(at coordinate: Coordinate, during interval: DateInterval) async throws -> TripWeatherForecast {
        try Task.checkCancellation()
        guard coordinate.isValid else { throw TripWeatherFailure.invalidLocation }
        guard interval.end > Date.now.addingTimeInterval(-TripWeatherHour.duration),
              interval.start < Date.now.addingTimeInterval(forecastHorizon) else { throw TripWeatherFailure.outsideForecastWindow }
        if let cached = cache[coordinate], cached.expiresAt > .now { return cached }
        if let task = pending[coordinate] { return try await task.value }
        guard pending.count < concurrentLocationLimit else { throw TripWeatherFailure.unavailable }
        let task = Task { try await WeatherRequest.fetch(coordinate) }
        pending[coordinate] = task
        defer { pending[coordinate] = nil }
        let forecast = try await withTaskCancellationHandler { try await task.value } onCancel: { task.cancel() }
        try Task.checkCancellation()
        remember(forecast, at: coordinate)
        return forecast
    }

    private func remember(_ forecast: TripWeatherForecast, at coordinate: Coordinate) {
        cache = cache.filter { $0.value.expiresAt > .now }
        if cache.count >= cacheLimit, let oldest = cache.min(by: { $0.value.issuedAt < $1.value.issuedAt })?.key {
            cache.removeValue(forKey: oldest)
        }
        cache[coordinate] = forecast
    }
}

import Foundation
import TripDomain

/// Bounds the whole day request as well as individual provider calls; cancellation reaches the provider.
nonisolated struct TripWeatherLoader: Sendable {
    private static let dayRequestBudget: TimeInterval = 30
    let service: any TripWeatherProviding

    func load(_ request: TripWeatherRequest) async -> TripWeatherLoadResult {
        var result = TripWeatherLoadResult()
        let deadline = Date.now.addingTimeInterval(Self.dayRequestBudget)
        for target in request.visits {
            guard !Task.isCancelled else { break }
            do { result.append(target, forecast: try await fetch(target, before: deadline)) }
            catch TripWeatherFailure.outsideForecastWindow { result.append(target, failed: false) }
            catch { result.append(target, failed: true) }
        }
        return result
    }

    private func fetch(_ target: TripWeatherTarget, before deadline: Date) async throws -> TripWeatherForecast {
        let remaining = deadline.timeIntervalSinceNow
        guard remaining > 0 else { throw TripWeatherFailure.timedOut }
        let interval = DateInterval(start: target.arrival, duration: TripWeatherHour.duration)
        return try await withThrowingTaskGroup(of: TripWeatherForecast.self) { group in
            group.addTask { try await service.forecast(at: target.coordinate, during: interval) }
            group.addTask {
                try await Task.sleep(for: .seconds(remaining))
                throw TripWeatherFailure.timedOut
            }
            defer { group.cancelAll() }
            guard let forecast = try await group.next() else { throw CancellationError() }
            return forecast
        }
    }
}

nonisolated struct TripWeatherLoadResult: Sendable {
    var visits: [TripWeatherVisit] = []
    var attribution: TripWeatherAttribution?
    var issuedAt: Date?
    var coverage: DateInterval?

    mutating func append(_ target: TripWeatherTarget, forecast: TripWeatherForecast) {
        visits.append(TripWeatherVisit(target: target, hour: forecast.hour(containing: target.arrival)))
        coverage = attribution == nil ? forecast.coverage : coverage.flatMap { shared in
            forecast.coverage.flatMap { shared.intersection(with: $0) }
        }
        attribution = forecast.attribution
        issuedAt = min(issuedAt ?? forecast.issuedAt, forecast.issuedAt)
    }

    mutating func append(_ target: TripWeatherTarget, failed: Bool) {
        visits.append(TripWeatherVisit(target: target, hour: nil, didFail: failed))
    }
}

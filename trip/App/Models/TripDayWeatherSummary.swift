import Foundation
import TripDomain
import TripLocalization

nonisolated struct TripDayWeatherSummary: Sendable {
    let text: String
    var attribution: TripWeatherAttribution?
    var issuedAt: Date?

    var shareText: String {
        guard let attribution else { return text }
        return "\(text)\n\(TripText.weatherDataSources.text): \(attribution.legalURL.absoluteString)"
    }
}

/// Weather is explicitly opted into and limited to the first timed place in the saved day.
@MainActor enum TripDayWeatherBriefing {
    static func load(for plan: TripPlan, date: Date, enabled: Bool,
                     service: any TripWeatherProviding) async -> TripDayWeatherSummary? {
        guard enabled else { return nil }
        if let issue = service.availabilityIssue { return TripDayWeatherSummary(text: issue) }
        guard let request = request(for: plan, date: date) else { return nil }
        let summary = await fetch(request, service: service)
        guard !Task.isCancelled, let latest = try? await AppRuntime.trip(plan.id),
              self.request(for: latest, date: date) == request else { return nil }
        return summary
    }

    private static func request(for plan: TripPlan, date: Date) -> TripWeatherRequest? {
        let briefing = TripDayBriefing(plan: TripSurfacePlan(plan), date: date)
        guard let day = plan.days.first(where: { $0.id == briefing.day?.id }) else { return nil }
        return TripWeatherRequest(trip: plan, day: day)
    }

    private static func fetch(_ request: TripWeatherRequest,
                              service: any TripWeatherProviding) async -> TripDayWeatherSummary {
        guard let target = request.visits.first else {
            return TripDayWeatherSummary(text: request.needsTimeReview ? TripText.weatherReviewTimeZone.text : TripText.weatherNeedsTimes.text)
        }
        do {
            let interval = DateInterval(start: target.arrival, duration: TripWeatherHour.duration)
            let forecast = try await service.forecast(at: target.coordinate, during: interval)
            guard let text = TripWeatherBriefing.summary(for: target, forecast: forecast, timeZoneID: request.timeZoneID) else {
                return TripDayWeatherSummary(text: TripText.weatherNoForecast.text)
            }
            return TripDayWeatherSummary(text: text, attribution: forecast.attribution, issuedAt: forecast.issuedAt)
        } catch TripWeatherFailure.outsideForecastWindow {
            return TripDayWeatherSummary(text: TripText.weatherNoForecast.text)
        } catch { return TripDayWeatherSummary(text: TripText.weatherLoadFailure.text) }
    }
}

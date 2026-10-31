import Foundation
import TripDomain
import TripLocalization

extension TripWeatherModel {
    var title: String { request?.title ?? TripText.weatherForDay.text }
    var availabilityIssue: String? { service.availabilityIssue }
    var canRefresh: Bool { availabilityIssue == nil && !isLoading && !needsSchedule }
    var timeZone: TimeZone { TimeZone(identifier: request?.timeZoneID ?? "UTC") ?? .gmt }
    var hasFailures: Bool { visits.contains(where: \.didFail) }
    var hasAdvice: Bool { visits.contains { $0.hour?.advice.isEmpty == false } }
    var needsSchedule: Bool { request?.visits.isEmpty != false }
    var omissionsMessage: String? {
        guard let request, request.omittedCount > 0 else { return nil }
        return TripText.weatherVisitLimit.text
    }
    var emptyMessage: String {
        request?.needsTimeReview == true ? TripText.weatherReviewTimeZone.text : TripText.weatherNeedsTimes.text
    }
}

extension TripWeatherAdvice {
    var label: String {
        switch self {
        case .rain: TripText.weatherRainAdvice.text
        case .heat: TripText.weatherHeatAdvice.text
        case .wind: TripText.weatherWindAdvice.text
        }
    }
    var symbol: String {
        switch self {
        case .rain: "cloud.rain"
        case .heat: "sun.max"
        case .wind: "wind"
        }
    }
}

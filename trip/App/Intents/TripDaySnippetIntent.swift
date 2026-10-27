import AppIntents
import SwiftUI
import Foundation
import TripDomain

struct TripDaySnippetIntent: SnippetIntent {
    static var title: LocalizedStringResource { "saved_trip_day" }
    static var isDiscoverable: Bool { false }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    @Parameter(title: "trip_identifier") var tripIdentifier: String
    @Parameter(title: "date") var date: Date
    @Parameter(title: "include_weather", default: false) var includeWeather: Bool

    init() {}
    init(tripID: UUID, date: Date, includeWeather: Bool = false) {
        tripIdentifier = tripID.uuidString
        self.date = date
        self.includeWeather = includeWeather
    }

    @MainActor func perform() async throws -> some IntentResult & ShowsSnippetView {
        guard let id = UUID(uuidString: tripIdentifier) else { throw TripIntentError.missingTrip }
        let trip = try await AppRuntime.trip(id)
        let weather = await TripDayWeatherBriefing.load(for: trip, date: date, enabled: includeWeather,
                                                       service: AppTripServices.weather)
        let latest = try await AppRuntime.trip(id)
        let briefing = TripDayBriefing(plan: TripSurfacePlan(latest), date: date)
        return .result(view: TripDayBriefingView(briefing: briefing, weather: weather, includeWeather: includeWeather))
    }
}

struct ShowTripDaySnippetIntent: AppIntent {
    static var title: LocalizedStringResource { "show_another_trip_day" }
    static var isDiscoverable: Bool { false }
    static var supportedModes: IntentModes { .background }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    @Parameter(title: "trip_identifier") var tripIdentifier: String
    @Parameter(title: "date") var date: Date
    @Parameter(title: "include_weather", default: false) var includeWeather: Bool

    init() {}
    init(tripID: UUID, date: Date, includeWeather: Bool = false) {
        tripIdentifier = tripID.uuidString
        self.date = date
        self.includeWeather = includeWeather
    }

    @MainActor func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        guard let id = UUID(uuidString: tripIdentifier) else { throw TripIntentError.missingTrip }
        let trip = try await AppRuntime.trip(id)
        guard TripDayBriefing(plan: TripSurfacePlan(trip), date: date).day != nil else { throw TripIntentError.missingDay }
        return .result(snippetIntent: TripDaySnippetIntent(tripID: id, date: date, includeWeather: includeWeather))
    }
}

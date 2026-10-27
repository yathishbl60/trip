import AppIntents
import SwiftUI
import Foundation
import TripDomain

struct ReadTripDayIntent: AppIntent {
    static var title: LocalizedStringResource { "read_my_trip_day" }
    static var description: IntentDescription { IntentDescription("get_aday_briefing_with_saved_places_travel_stays") }
    static var supportedModes: IntentModes { .background }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip") var trip: SavedTripEntity
    @Parameter(title: "date") var date: Date?
    @Parameter(title: "include_weather", default: false) var includeWeather: Bool
    static var parameterSummary: some ParameterSummary {
        Summary("Read a day in \(\ReadTripDayIntent.$trip as KeyPath<ReadTripDayIntent, Parameter<SavedTripEntity>>)") {
            \ReadTripDayIntent.$date as KeyPath<ReadTripDayIntent, Parameter<Date?>>
            \ReadTripDayIntent.$includeWeather as KeyPath<ReadTripDayIntent, Parameter<Bool>>
        }
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog & ShowsSnippetIntent {
        let plan = try await AppRuntime.trip(trip.id)
        let date = date ?? .now
        let weather = await TripDayWeatherBriefing.load(for: plan, date: date, enabled: includeWeather,
                                                       service: AppTripServices.weather)
        let latest = try await AppRuntime.trip(plan.id)
        let briefing = TripDayBriefing(plan: TripSurfacePlan(latest), date: date)
        let text = [briefing.text, weather?.shareText].compactMap { $0 }.joined(separator: "\n")
        let spoken = [briefing.spokenSummary, weather?.text].compactMap { $0 }.joined(separator: " ")
        return .result(value: text, dialog: IntentDialog(stringLiteral: spoken),
                       snippetIntent: TripDaySnippetIntent(tripID: plan.id, date: date, includeWeather: includeWeather))
    }
}

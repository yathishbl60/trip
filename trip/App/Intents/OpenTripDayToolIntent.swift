import AppIntents
import Foundation

@AppIntent(.tool)
struct OpenTripDayToolIntent {
    static var title: LocalizedStringResource { "intent_open_day_tool" }
    static var description: IntentDescription { IntentDescription("intent_open_day_tool_description") }
    static var supportedModes: IntentModes { .foreground }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    @Parameter(title: "day_number", description: "intent_parameter_day_number", inclusiveRange: (1, 30)) var day: Int
    @Parameter(title: "intent_day_tool", description: "intent_parameter_day_tool") var tool: TripDayTool

    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\OpenTripDayToolIntent.$tool as KeyPath<OpenTripDayToolIntent, Parameter<TripDayTool>>) for day \(\OpenTripDayToolIntent.$day as KeyPath<OpenTripDayToolIntent, Parameter<Int>>) of \(\OpenTripDayToolIntent.$trip as KeyPath<OpenTripDayToolIntent, Parameter<SavedTripEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult {
        try await AppRuntime.openDayTool(tool, tripID: trip.id, number: day)
        return .result()
    }
}

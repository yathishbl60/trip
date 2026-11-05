import AppIntents
import Foundation

@AppIntent(.tool)
struct OpenTripToolIntent {
    static var title: LocalizedStringResource { "intent_open_trip_tool" }
    static var description: IntentDescription { IntentDescription("intent_open_trip_tool_description") }
    static var supportedModes: IntentModes { .foreground }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    @Parameter(title: "intent_trip_tool", description: "intent_parameter_trip_tool") var tool: TripWorkspaceTool

    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\OpenTripToolIntent.$tool as KeyPath<OpenTripToolIntent, Parameter<TripWorkspaceTool>>) for \(\OpenTripToolIntent.$trip as KeyPath<OpenTripToolIntent, Parameter<SavedTripEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult {
        try await AppRuntime.openWorkspaceTool(tool, tripID: trip.id)
        return .result()
    }
}

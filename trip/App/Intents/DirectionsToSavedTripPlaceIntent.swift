import AppIntents

@AppIntent(.tool)
struct DirectionsToSavedTripPlaceIntent {
    static var title: LocalizedStringResource { "intent_directions_saved_visit" }
    static var description: IntentDescription { IntentDescription("intent_directions_saved_visit_description") }
    static var supportedModes: IntentModes { .foreground }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "place", description: "intent_parameter_directions_visit") var place: SavedTripDetailEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Get directions to \(\DirectionsToSavedTripPlaceIntent.$place as KeyPath<DirectionsToSavedTripPlaceIntent, Parameter<SavedTripDetailEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult & OpensIntent {
        let url = try await AppRuntime.directionsToSavedVisit(place.id)
        return .result(opensIntent: OpenURLIntent(url))
    }
}

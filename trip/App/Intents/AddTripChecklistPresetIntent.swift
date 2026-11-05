import AppIntents

@AppIntent(.tool)
struct AddTripChecklistPresetIntent {
    static var title: LocalizedStringResource { "intent_add_checklist_preset" }
    static var description: IntentDescription { IntentDescription("intent_add_checklist_preset_description") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    @Parameter(title: "intent_checklist_preset", description: "intent_parameter_checklist_preset") var preset: TripChecklistPreset

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\AddTripChecklistPresetIntent.$preset as KeyPath<AddTripChecklistPresetIntent, Parameter<TripChecklistPreset>>) to \(\AddTripChecklistPresetIntent.$trip as KeyPath<AddTripChecklistPresetIntent, Parameter<SavedTripEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<[SavedTripChecklistEntity]> {
        .result(value: try await AppRuntime.addChecklistTemplate(preset.template, tripID: trip.id))
    }
}

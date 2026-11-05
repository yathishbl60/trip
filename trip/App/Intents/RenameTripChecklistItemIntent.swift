import AppIntents

@AppIntent(.tool)
struct RenameTripChecklistItemIntent {
    static var title: LocalizedStringResource { "intent_rename_checklist_item" }
    static var description: IntentDescription { IntentDescription("intent_rename_checklist_item_description") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "item", description: "intent_parameter_checklist_item") var item: SavedTripChecklistEntity
    @Parameter(title: "title", description: "intent_parameter_checklist_new_title") var title: String

    static var parameterSummary: some ParameterSummary {
        Summary("Rename \(\RenameTripChecklistItemIntent.$item as KeyPath<RenameTripChecklistItemIntent, Parameter<SavedTripChecklistEntity>>) to \(\RenameTripChecklistItemIntent.$title as KeyPath<RenameTripChecklistItemIntent, Parameter<String>>)")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<SavedTripChecklistEntity> {
        .result(value: try await AppRuntime.renameChecklistItem(item.id, title: title))
    }
}

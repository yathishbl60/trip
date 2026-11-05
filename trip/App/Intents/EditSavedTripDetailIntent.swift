import AppIntents
import TripDomain

@AppIntent(.tool)
struct EditSavedTripDetailIntent {
    static var title: LocalizedStringResource { "intent_edit_saved_detail" }
    static var description: IntentDescription { IntentDescription("intent_edit_saved_detail_description") }
    static var supportedModes: IntentModes { .foreground }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "detail", description: "intent_parameter_saved_detail") var detail: SavedTripDetailEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Edit \(\EditSavedTripDetailIntent.$detail as KeyPath<EditSavedTripDetailIntent, Parameter<SavedTripDetailEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult {
        guard let identity = TripDetailIdentity(detail.id) else { throw TripDetailIntentError.missingDetail }
        try await AppRuntime.editDetail(identity)
        return .result()
    }
}

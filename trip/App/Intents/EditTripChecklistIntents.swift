import TripLocalization
import AppIntents

struct AddTripChecklistItemIntent: AppIntent {
    static var title: LocalizedStringResource { "add_trip_checklist_item" }
    static var description: IntentDescription { IntentDescription("add_one_preparation_or_packing_item_existing_items_are") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    @Parameter(title: "item", description: "intent_parameter_checklist_title") var title: String
    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\AddTripChecklistItemIntent.$title as KeyPath<AddTripChecklistItemIntent, Parameter<String>>) to \(\AddTripChecklistItemIntent.$trip as KeyPath<AddTripChecklistItemIntent, Parameter<SavedTripEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<SavedTripChecklistEntity> & ProvidesDialog {
        let item = try await AppRuntime.addChecklistItem(title, tripID: trip.id)
        return .result(value: item, dialog: IntentDialog(TripText.valueIsOnYourChecklist(item.title).resource))
    }
}

struct SetTripChecklistItemIntent: AppIntent {
    static var title: LocalizedStringResource { "set_trip_checklist_item_completion" }
    static var description: IntentDescription { IntentDescription("mark_an_exact_checklist_item_done_or_incomplete_repeated") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "item", description: "intent_parameter_checklist_item") var item: SavedTripChecklistEntity
    @Parameter(title: "complete", description: "intent_parameter_checklist_complete", default: true) var complete: Bool
    static var parameterSummary: some ParameterSummary {
        Summary("Set \(\SetTripChecklistItemIntent.$item as KeyPath<SetTripChecklistItemIntent, Parameter<SavedTripChecklistEntity>>) completion to \(\SetTripChecklistItemIntent.$complete as KeyPath<SetTripChecklistItemIntent, Parameter<Bool>>)")
    }

    init() {}
    init(item: SavedTripChecklistEntity, complete: Bool) {
        self.item = item
        self.complete = complete
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<SavedTripChecklistEntity> {
        .result(value: try await AppRuntime.setChecklistItem(item.id, complete: complete))
    }
}

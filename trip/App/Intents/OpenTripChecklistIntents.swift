import TripLocalization
import AppIntents
import Foundation
import TripDomain

struct OpenTripChecklistIntent: AppIntent {
    static var title: LocalizedStringResource { "open_trip_checklist" }
    static var description: IntentDescription { IntentDescription("intent_open_checklist_description") }
    static var supportedModes: IntentModes { .foreground }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    static var parameterSummary: some ParameterSummary {
        Summary("Open the checklist for \(\OpenTripChecklistIntent.$trip as KeyPath<OpenTripChecklistIntent, Parameter<SavedTripEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult {
        let plan = try await AppRuntime.trip(trip.id)
        try AppRuntime.openChecklist(plan.id)
        return .result()
    }
}

struct SuggestTripPackingIntent: AppIntent {
    static var title: LocalizedStringResource { "suggest_packing_with_apple_intelligence" }
    static var description: IntentDescription { IntentDescription("open_the_on_device_packing_assistant_review_and_select") }
    static var supportedModes: IntentModes { .foreground }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    @Parameter(title: "preferences", description: "intent_parameter_preferences", default: "") var preferences: String
    static var parameterSummary: some ParameterSummary {
        Summary("Suggest packing for \(\SuggestTripPackingIntent.$trip as KeyPath<SuggestTripPackingIntent, Parameter<SavedTripEntity>>)") {
            \SuggestTripPackingIntent.$preferences as KeyPath<SuggestTripPackingIntent, Parameter<String>>
        }
    }

    @MainActor func perform() async throws -> some IntentResult & ProvidesDialog {
        let plan = try await AppRuntime.trip(trip.id)
        try AppRuntime.openChecklist(plan.id, preferences: preferences)
        return .result(dialog: IntentDialog(TripText.openingPackingSuggestionsInTripReviewBeforeAddingItems.resource))
    }
}

extension AppRuntime {
    static func openChecklist(_ id: UUID, preferences: String? = nil) throws {
        guard activeScene?.trips.hasEditingSession != true else { throw TripDetailIntentError.editing }
        AppLaunchModel.shared.open(.checklist(id, preferences))
    }
}

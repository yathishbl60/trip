import AppIntents
import TripDomain

enum TripChecklistFilter: String, AppEnum {
    case pending, completed, all
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "checklist_filter") }
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [.pending: DisplayRepresentation(title: "to_do"), .completed: DisplayRepresentation(title: "done"), .all: DisplayRepresentation(title: "all_items")]
    }

    func includes(_ item: TripChecklistItem) -> Bool {
        switch self {
        case .pending: !item.isComplete
        case .completed: item.isComplete
        case .all: true
        }
    }
}

struct GetTripChecklistIntent: AppIntent {
    static var title: LocalizedStringResource { "get_trip_checklist_items" }
    static var description: IntentDescription { IntentDescription("return_checklist_items_for_filtering_reading_and_completing_in") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    @Parameter(title: "filter", default: .pending) var filter: TripChecklistFilter
    static var parameterSummary: some ParameterSummary {
        Summary("Get checklist items from \(\GetTripChecklistIntent.$trip as KeyPath<GetTripChecklistIntent, Parameter<SavedTripEntity>>)") {
            \GetTripChecklistIntent.$filter as KeyPath<GetTripChecklistIntent, Parameter<TripChecklistFilter>>
        }
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<[SavedTripChecklistEntity]> {
        let plan = try await AppRuntime.trip(trip.id)
        let items = plan.checklist.prefix(TripLimits.checklistItems).filter(filter.includes)
        return .result(value: items.map { SavedTripChecklistEntity($0, plan: plan) })
    }
}

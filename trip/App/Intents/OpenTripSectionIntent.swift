import AppIntents
import Foundation

@AppIntent(.tool)
struct OpenTripSectionIntent {
    static var title: LocalizedStringResource { "intent_open_trip_section" }
    static var description: IntentDescription { IntentDescription("intent_open_trip_section_description") }
    static var supportedModes: IntentModes { .foreground }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    @Parameter(title: "intent_trip_section", description: "intent_parameter_section") var section: TripSection

    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\OpenTripSectionIntent.$section as KeyPath<OpenTripSectionIntent, Parameter<TripSection>>) in \(\OpenTripSectionIntent.$trip as KeyPath<OpenTripSectionIntent, Parameter<SavedTripEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult {
        try await AppRuntime.openSection(section, tripID: trip.id)
        return .result()
    }
}

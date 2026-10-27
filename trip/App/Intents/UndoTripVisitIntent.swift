import TripLocalization
import AppIntents
import TripDomain

struct UndoTripVisitIntent: TripTrackingIntent {
    static var title: LocalizedStringResource { "undo_last_trip_visit" }
    static var description: IntentDescription { IntentDescription("restore_the_last_place_marked_visited_in_your_tracked") }
    static var supportedModes: IntentModes { .background }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    static var parameterSummary: some ParameterSummary { Summary("Undo my last recorded trip visit") }

    @MainActor func perform() async throws -> some IntentResult & ProvidesDialog {
        await TripJourneyRuntime.shared.refresh()
        guard TripJourneyRuntime.shared.journey?.visited.isEmpty == false else {
            return .result(dialog: IntentDialog(TripText.thereIsnTARecordedVisitToUndo.resource))
        }
        try await TripJourneyRuntime.shared.undo()
        return .result(dialog: IntentDialog(TripText.restoredTheLastVisitOpenTripToSeeYour.resource))
    }
}

import TripLocalization
import AppIntents
import Foundation

#if os(iOS)
typealias TripTrackingIntent = LiveActivityIntent
#else
typealias TripTrackingIntent = AppIntent
#endif

struct CompleteTripStopIntent: TripTrackingIntent {
    static var title: LocalizedStringResource { "mark_next_place_visited" }
    static var isDiscoverable: Bool { false }
    static var supportedModes: IntentModes { .background }
    @Parameter(title: "stop_identifier", default: "") var stopIdentifier: String
    @Parameter(title: "trip_identifier", default: "") var tripIdentifier: String
    @Parameter(title: "day_identifier", default: "") var dayIdentifier: String

    init() {}
    init(stopID: UUID, tripID: UUID, dayID: UUID) {
        stopIdentifier = stopID.uuidString
        tripIdentifier = tripID.uuidString
        dayIdentifier = dayID.uuidString
    }

    @MainActor func perform() async throws -> some IntentResult {
        guard let id = UUID(uuidString: stopIdentifier), let tripID = UUID(uuidString: tripIdentifier),
              let dayID = UUID(uuidString: dayIdentifier) else { return .result() }
        try await TripJourneyRuntime.shared.advance(expectedStopID: id, tripID: tripID, dayID: dayID)
        return .result()
    }
}

struct EndTripDayIntent: TripTrackingIntent {
    static var title: LocalizedStringResource { "intent_end_trip_day_tracking" }
    static var supportedModes: IntentModes { .background }
    static var parameterSummary: some ParameterSummary { Summary("End trip day tracking") }

    @MainActor func perform() async throws -> some IntentResult & ProvidesDialog {
        try await TripJourneyRuntime.shared.end()
        return .result(dialog: IntentDialog(TripText.tripDayTrackingEnded.resource))
    }
}

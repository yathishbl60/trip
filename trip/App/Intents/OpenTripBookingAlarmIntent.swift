#if os(iOS)
import AppIntents
import Foundation
import TripDomain

/// Alarm actions enter the same validated detail-navigation path as saved-item links.
struct OpenTripBookingAlarmIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "open_saved_trip_detail" }
    static var isDiscoverable: Bool { false }
    static var supportedModes: IntentModes { .foreground }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip_identifier") var tripIdentifier: String
    @Parameter(title: "detail", description: "intent_parameter_saved_detail") var eventIdentifier: String

    init() {}

    init(tripID: UUID, eventID: UUID) {
        tripIdentifier = tripID.uuidString
        eventIdentifier = eventID.uuidString
    }

    @MainActor func perform() async throws -> some IntentResult {
        guard let tripID = UUID(uuidString: tripIdentifier),
              let eventID = UUID(uuidString: eventIdentifier) else { throw TripDetailIntentError.missingDetail }
        try await AppRuntime.openDetail(TripDetailIdentity(tripID: tripID, itemID: eventID))
        return .result()
    }
}
#endif

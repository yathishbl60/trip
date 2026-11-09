import TripLocalization
import AppIntents
import Foundation

/// Shared metadata; foreground execution is restricted to the host app.
struct OpenTripControlIntent: AppIntent {
    static var title: LocalizedStringResource { "open_trip_surface" }
    static var isDiscoverable: Bool { false }
    static var supportedModes: IntentModes { .foreground }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip_identifier") var tripIdentifier: String
    @Parameter(title: "surface") var surface: String
    init() {}
    init(tripID: UUID?, surface: String) {
        tripIdentifier = tripID?.uuidString ?? ""
        self.surface = surface
    }

    @MainActor func perform() async throws -> some IntentResult {
        guard let id = UUID(uuidString: tripIdentifier) else { throw TripControlError.unconfigured }
        guard ["itinerary", "checklist", "nextStep"].contains(surface) else { throw TripControlError.unconfigured }
        guard let open = TripControlNavigation.open else { throw TripControlError.unavailable }
        try await open(id, surface)
        return .result()
    }
}

@MainActor enum TripControlNavigation {
    static var open: (@MainActor (UUID, String) async throws -> Void)?
}

nonisolated enum TripControlError: LocalizedError, CustomLocalizedStringResourceConvertible {
    case unavailable, unconfigured
    var errorDescription: String? { String(localized: localizedStringResource) }
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .unavailable: TripText.openTripOnceThenTryThisControlAgain.resource
        case .unconfigured: TripText.editThisControlAndChooseASavedTripFirst.resource
        }
    }
}

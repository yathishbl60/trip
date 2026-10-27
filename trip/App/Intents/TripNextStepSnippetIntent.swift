import AppIntents
import Foundation
import SwiftUI

struct TripNextStepSnippetIntent: SnippetIntent {
    static var title: LocalizedStringResource { "next_trip_step" }
    static var isDiscoverable: Bool { false }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip_identifier") var tripIdentifier: String

    init() {}
    init(tripID: UUID) { tripIdentifier = tripID.uuidString }

    @MainActor func perform() async throws -> some IntentResult & ShowsSnippetView {
        guard let id = UUID(uuidString: tripIdentifier) else { throw TripIntentError.missingTrip }
        let next = try await AppRuntime.nextStep(tripID: id)
        return .result(view: TripNextStepView(next: next))
    }
}

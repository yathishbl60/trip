import Foundation
import AppIntents
import TripDomain

extension AppRuntime {
    static func installControls() {
        TripJourneyRuntime.shared.onChange = { TripNextStepSnippetIntent.reload() }
        TripControlNavigation.open = { id, surface in
            let plan = try await trip(id)
            guard activeScene?.trips.hasEditingSession != true else { throw TripDetailIntentError.editing }
            if surface == "nextStep" { try await openNextStep(tripID: plan.id) }
            else if surface == "checklist" { try openChecklist(plan.id) }
            else { openTrip(plan.id) }
        }
    }
}

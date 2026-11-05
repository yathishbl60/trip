import Foundation
import TripDomain

extension AppRuntime {
    static func draftTrip(tripID: UUID, preferences: String, days: Int, processing: TripAIProcessing = .onDevice) async throws {
        let plan = try await trip(tripID)
        guard !plan.savedPlaces.isEmpty else { throw TripIntentError.noPlaces }
        let assistant = AppTripServices.makeAssistant()
        assistant.setProcessing(processing)
        assistant.refreshAvailability()
        if let reason = assistant.unavailableReason { throw TripIntelligenceError.unavailable(reason) }
        AppLaunchModel.shared.open(.draftTrip(tripID, preferences, days, processing))
    }
}

nonisolated enum TripIntelligenceError: LocalizedError, CustomLocalizedStringResourceConvertible {
    case unavailable(String)

    var errorDescription: String? { String(localized: localizedStringResource) }

    var localizedStringResource: LocalizedStringResource {
        switch self { case .unavailable(let reason): "\(reason)" }
    }
}

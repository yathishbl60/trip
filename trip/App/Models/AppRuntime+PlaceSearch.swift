import Foundation
import TripDomain

extension AppRuntime {
    static func searchPlace(text: String, tripID: UUID, dayNumber: Int) async throws -> String {
        let plan = try await trip(tripID)
        guard let day = plan.days.first(where: { $0.number == dayNumber }) else {
            throw TripIntentError.missingDay
        }
        let request = try TripPlaceSearchRequest(tripID: plan.id, dayID: day.id, text: text)
        try Task.checkCancellation()
        guard activeScene?.trips.hasEditingSession != true else {
            throw TripPlaceSearchIntentError.editing
        }
        AppLaunchModel.shared.open(.searchPlace(request))
        return plan.title
    }
}

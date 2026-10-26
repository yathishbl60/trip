import Foundation
import TripDomain

extension AppRuntime {
    static func importBooking(_ document: TripBookingDocument, tripID: UUID, dayNumber: Int) async throws {
        let plan = try await trip(tripID)
        guard let day = plan.days.first(where: { $0.number == dayNumber }) else { throw TripIntentError.missingDay }
        try Task.checkCancellation()
        guard activeScene?.trips.hasEditingSession != true else { throw TripPlaceSearchIntentError.editing }
        let request = try TripBookingImportRequest(tripID: plan.id, dayID: day.id, document: document)
        AppLaunchModel.shared.open(.importBooking(request))
    }
}

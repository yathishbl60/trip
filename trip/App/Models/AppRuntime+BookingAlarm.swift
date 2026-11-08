import Foundation
import TripDomain
import TripLocalization

extension AppRuntime {
    static func reviewBookingAlarm(_ identity: TripDetailIdentity) async throws {
        guard AppTripServices.systemActions.supportsAlarms else { throw TripSystemActionError.unavailable }
        let plan = try await trip(identity.tripID)
        try Task.checkCancellation()
        guard activeScene?.trips.hasEditingSession != true else { throw TripDetailIntentError.editing }
        try TripBookingAlarmIntentError.validate(identity, in: plan)
        AppLaunchModel.shared.open(.bookingAlarm(identity))
    }
}

nonisolated enum TripBookingAlarmIntentError: LocalizedError, CustomLocalizedStringResourceConvertible {
    case bookingRequired
    var errorDescription: String? { String(localized: localizedStringResource) }
    var localizedStringResource: LocalizedStringResource { TripText.chooseSavedBookingForAlarm.resource }

    static func validate(_ identity: TripDetailIdentity, in plan: TripPlan) throws {
        guard identity.tripID == plan.id else { throw TripDetailIntentError.missingDetail }
        guard let event = plan.events.first(where: { $0.id == identity.itemID }) else {
            if plan.days.contains(where: { $0.stops.contains { $0.id == identity.itemID } }) { throw Self.bookingRequired }
            throw TripDetailIntentError.missingDetail
        }
        guard event.dayRange(in: plan) != nil else { throw TripDetailIntentError.missingDetail }
    }
}

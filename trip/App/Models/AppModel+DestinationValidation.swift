import Foundation
import TripDomain

extension AppModel {
    func navigationPlan(_ id: UUID) -> TripPlan? {
        guard trips.library.isReady else {
            navigation.notice = TripIntentError.libraryUnavailable.errorDescription
            return nil
        }
        guard let plan = trips.library.trip(id) else {
            navigation.notice = TripIntentError.missingTrip.errorDescription
            return nil
        }
        return plan
    }

    func validateDetail(_ identity: TripDetailIdentity) -> Bool {
        guard let plan = navigationPlan(identity.tripID) else { return false }
        guard identity.resolve(in: TripSurfacePlan(plan)) != nil else {
            navigation.notice = TripDetailIntentError.missingDetail.errorDescription
            return false
        }
        return true
    }

    func openNewEvent(_ request: TripNewEventRequest) {
        guard let plan = navigationPlan(request.tripID) else { return }
        do {
            try request.validate(in: plan)
            guard openSavedTrip(plan.id, resetDestination: false) else { return }
            try trips.beginNewEvent(request)
        } catch { navigation.notice = error.localizedDescription }
    }
}

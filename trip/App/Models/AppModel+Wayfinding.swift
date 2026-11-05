import Foundation
import TripDomain

extension AppModel {
    func openTripLibrary() {
        guard allowNavigation() else { return }
        navigation.tab = .trips
        trips.selectTrip(nil)
    }

    func openWorkspace(_ destination: AppDestination) {
        switch destination {
        case .section(let id, let section):
            guard openSavedTrip(id, resetDestination: false) else { return }
            trips.openSection(section, tripID: id)
        case .workspaceTool(let id, let tool):
            openReview(tool, tripID: id)
        case .dayTool(let id, let dayID, let tool):
            openDayTool(tool, tripID: id, dayID: dayID)
        case .editDetail(let identity):
            guard validateDetail(identity) else { return }
            openDetail(identity)
            trips.editSavedDetail(identity.itemID, tripID: identity.tripID)
        case .newEvent(let request): openNewEvent(request)
        default: break
        }
    }

    private func openDayTool(_ tool: TripDayTool, tripID: UUID, dayID: UUID) {
        guard let plan = navigationPlan(tripID) else { return }
        guard plan.days.contains(where: { $0.id == dayID }) else {
            navigation.notice = TripIntentError.missingDay.errorDescription
            return
        }
        guard openSavedTrip(tripID, resetDestination: false) else { return }
        trips.openDayTool(tool, dayID: dayID, tripID: tripID)
    }

    private func openReview(_ tool: TripWorkspaceTool, tripID: UUID) {
        guard tool == .tripDetails || trips.systemActions.service.supportsCalendarReminders else {
            navigation.notice = TripSystemActionError.unavailable.errorDescription
            return
        }
        guard openSavedTrip(tripID, resetDestination: false) else { return }
        trips.openWorkspaceTool(tool, tripID: tripID)
    }
}

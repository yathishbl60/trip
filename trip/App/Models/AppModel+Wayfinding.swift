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
            guard openSavedTrip(id) else { return }
            trips.openSection(section, tripID: id)
        case .workspaceTool(let id, let tool):
            guard openSavedTrip(id) else { return }
            trips.openWorkspaceTool(tool, tripID: id)
        case .dayTool(let id, let dayID, let tool):
            guard openSavedTrip(id) else { return }
            trips.openDayTool(tool, dayID: dayID, tripID: id)
        case .editDetail(let identity):
            openDetail(identity)
            trips.editSavedDetail(identity.itemID, tripID: identity.tripID)
        default: break
        }
    }
}

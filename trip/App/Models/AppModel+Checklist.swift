import Foundation

extension AppModel {
    func openChecklist(_ id: UUID, preferences: String? = nil) {
        guard !trips.hasEditingSession else { return }
        guard openSavedTrip(id) else { return }
        trips.presentation.detailRoute = nil
        trips.openDetail(.checklist, tripID: id)
        if let preferences {
            trips.openPacking(id)
            trips.packing.setPreferences(preferences)
        }
    }
}

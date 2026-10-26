import Foundation

extension AppModel {
    func restore(tab: String, tripID: String, initialTripID: UUID?) async {
        guard !navigation.didRestore else { return }
        navigation.didRestore = true
        await trips.library.load()
        guard !Task.isCancelled else { navigation.didRestore = false; return }
        guard trips.library.isReady else { navigation.didRestore = false; return }
        navigation.tab = AppTab(rawValue: tab) == .trips ? .trips : .explore
        if let id = initialTripID ?? UUID(uuidString: tripID), trips.library.trip(id) != nil {
            if initialTripID != nil { openSavedTrip(id) }
            else if allowNavigation() { trips.selectTrip(id) }
        }
    }
}

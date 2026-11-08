extension AppModel {
    func selectTab(_ tab: AppTab) {
        navigation.beginRequest()
        navigation.tab = tab
    }

    func allowNavigation() -> Bool {
        guard trips.hasEditingSession else { return true }
        if let message = TripDetailIntentError.editing.errorDescription {
            trips.showNavigationNotice(message)
        }
        return false
    }
}

extension AppModel {
    func cancelPendingLink() {
        navigation.linkTask?.cancel()
        navigation.linkTask = nil
    }

    func selectTab(_ tab: AppTab) {
        cancelPendingLink()
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

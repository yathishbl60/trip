import TripDomain

extension TripModel {
    func configureChecklist() {
        checklist.environment = TripChecklistEnvironment(
            showFeedback: { [weak feedback] in feedback?.show($0) },
            supportsReminders: { [weak systemActions] in systemActions?.service.supportsCalendarReminders == true },
            showReminders: { [weak self] in self?.openWorkspaceTool(.reminders, tripID: $0) },
            entityIdentifier: environment.checklistEntityIdentifier
        )
    }
}

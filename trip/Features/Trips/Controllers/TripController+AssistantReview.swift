import SwiftUI

extension TripController {
    var confirmingAssistantPlan: Binding<Bool> {
        Binding(get: { model.assistant.isConfirmingApply }, set: { model.assistant.isConfirmingApply = $0 })
    }

    func requestAssistantApply(_ id: UUID) {
        guard model.assistantApplyIssue(id) == nil else { return }
        model.assistant.isConfirmingApply = true
    }

    func applyAssistantPlan(_ id: UUID) { model.applyAssistantPlan(id) }
    func refineAssistant(_ choice: TripPlanRefinement, tripID: UUID) { model.refineAssistant(choice, tripID: tripID) }
    func findAssistantPlaces(_ id: UUID) { model.findAssistantPlaces(id) }
}

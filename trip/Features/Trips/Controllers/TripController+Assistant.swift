import SwiftUI
import TripDomain

extension TripController {
    var planningProcessing: Binding<TripAIProcessing> {
        Binding(get: { model.assistant.processing }, set: model.assistant.setProcessing)
    }

    var assistantPresentation: Binding<Bool> {
        Binding(get: { model.presentation.assistantTripID != nil }, set: { if !$0 { dismissAssistant() } })
    }

    var preferences: Binding<String> {
        Binding(get: { model.assistant.preferences }, set: model.assistant.setPreferences)
    }

    var planningDayCount: Binding<Int> {
        Binding(get: { model.assistant.dayCount }, set: model.assistant.setDayCount)
    }

    var planningPace: Binding<TripPlanningPace> {
        Binding(get: { model.assistant.pace }, set: model.assistant.setPace)
    }

    var planningFocus: Binding<TripPlanningFocus> {
        Binding(get: { model.assistant.focus }, set: model.assistant.setFocus)
    }

    var planningPlaceQuery: Binding<String> {
        Binding(get: { model.assistant.selection.query }, set: { model.assistant.selection.query = $0 })
    }

    func planningPlaceSelected(_ id: String) -> Binding<Bool> {
        Binding(get: { model.assistant.selection.selectedIDs.contains(id) },
                set: { model.assistant.setPlaceSelected($0, id: id) })
    }

    func openAssistant(_ id: UUID) { model.openAssistant(id) }
    func generatePlan(_ id: UUID) { model.generatePlan(id) }
    func refreshAssistantPlaces(_ id: UUID) { model.refreshAssistantPlaces(id) }
    func refreshIntelligenceAvailability() { model.assistant.refreshAvailability() }
    func selectAllPlanningPlaces(_ selected: Bool) { model.assistant.selectAllPlaces(selected) }
    func cancelGeneration() { model.assistant.cancel() }
    func dismissAssistant() { model.dismissAssistant() }
    func saveAssistantPlan(_ id: UUID) { _ = model.saveAssistantPlan(for: id) }
}

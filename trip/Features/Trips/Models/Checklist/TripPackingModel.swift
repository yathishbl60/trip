import TripLocalization
import Foundation
import Observation
import TripDomain

nonisolated struct TripPackingSuggestion: Identifiable {
    let title: String
    var id: String { TripChecklistEditing.key(title) }
}

@MainActor @Observable final class TripPackingModel {
    var preferences = ""
    var suggestions: [TripPackingSuggestion] = []
    var selected: Set<String> = []
    var isGenerating = false
    var error: String?
    var unavailableReason: String?
    var context: TripPackingContext?
    var selectedTitles: [String] { suggestions.filter { selected.contains($0.id) }.map(\.title) }
    @ObservationIgnored var generation = 0
    @ObservationIgnored var task: Task<Void, Never>?
    @ObservationIgnored var deadline: Task<Void, Never>?
    @ObservationIgnored var existingItems: [TripChecklistItem] = []
    @ObservationIgnored let client: TripAIClient<any TripPackingPlanning>

    init(client: TripAIClient<any TripPackingPlanning>) { self.client = client }

    func prepare(_ plan: TripPlan) {
        cancel()
        context = TripPackingContext(plan)
        existingItems = plan.checklist
        preferences = ""
        suggestions = []
        selected = []
        error = nil
        refreshAvailability()
    }

    func refreshAvailability() { unavailableReason = client.availability(.onDevice) }

    func setPreferences(_ value: String) {
        guard preferences != value else { return }
        cancel()
        preferences = String(value.prefix(TripLimits.preferenceCharacters))
        suggestions = []
        selected = []
        error = nil
    }

    func refresh(_ plan: TripPlan?) {
        guard let plan else { cancel(); return }
        existingItems = plan.checklist
        if context != TripPackingContext(plan) {
            cancel()
            context = TripPackingContext(plan)
            suggestions = []
            selected = []
            error = TripText.yourItineraryChangedGenerateAFreshPackingList.text
        }
        let missing = Set(TripChecklistEditing.missing(suggestions.map(\.title), from: plan.checklist).map(TripChecklistEditing.key))
        suggestions.removeAll { !missing.contains($0.id) }
        selected.formIntersection(missing)
    }

    func cancel() {
        generation += 1
        task?.cancel()
        deadline?.cancel()
        task = nil
        deadline = nil
        isGenerating = false
    }
}

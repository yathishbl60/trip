import TripDomain
import TripLocalization
import Foundation

extension TripModel {
    func openAssistant(_ id: UUID) {
        guard let trip = library.trip(id) else { return }
        assistant.reset(for: trip)
        presentation.assistantTripID = id
    }

    func generatePlan(_ id: UUID) {
        guard presentation.assistantTripID == id, let trip = library.trip(id) else { return }
        assistant.generate(from: trip)
    }

    func dismissAssistant() {
        assistant.cancel()
        if presentation.assistantTripID != nil {
            presentation.savedPlacePicker?.cancelSearch()
            presentation.savedPlacePicker = nil
        }
        presentation.assistantTripID = nil
    }

    func saveAssistantPlan(for id: UUID) -> UUID? {
        guard presentation.assistantTripID == id, let source = library.trip(id) else { return nil }
        assistant.reconcilePlaces(source.savedPlaces)
        guard library.canCreate, assistant.canSaveDraft else { return nil }
        let suffix = TripText.valueNewPlan("").text
        let title = String(source.title.prefix(max(0, TripLimits.titleCharacters - suffix.count)))
        var plan = TripPlan(title: TripText.valueNewPlan(title).text)
        plan.startDate = source.startDate
        plan.days = assistant.daysPreservingDetails(from: source)
        plan.collections = source.collections
        plan.notes = source.notes
        plan.checklist = source.checklist.map { TripChecklistItem(title: $0.title) }
        guard library.insert(plan) else { return nil }
        presentation.assistantTripID = nil
        selectTrip(plan.id)
        return plan.id
    }

    func refreshAssistantPlaces(_ id: UUID) {
        guard presentation.assistantTripID == id else { return }
        assistant.reconcilePlaces(library.trip(id)?.savedPlaces ?? [])
    }
}

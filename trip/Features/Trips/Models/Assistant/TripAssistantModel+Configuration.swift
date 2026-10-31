import TripDomain
import Foundation

extension TripAssistantModel {
    func setPreferences(_ value: String) {
        let value = String(value.prefix(TripLimits.preferenceCharacters))
        guard preferences != value else { return }
        invalidateDraft()
        preferences = value
    }

    func setDayCount(_ value: Int) {
        let value = min(max(value, TripLimits.planningDays.lowerBound), TripLimits.planningDays.upperBound)
        guard dayCount != value else { return }
        invalidateDraft()
        dayCount = value
    }

    func setPace(_ value: TripPlanningPace) {
        guard pace != value else { return }
        invalidateDraft()
        pace = value
    }

    func setFocus(_ value: TripPlanningFocus) {
        guard focus != value else { return }
        invalidateDraft()
        focus = value
    }

    func setPlaceSelected(_ value: Bool, id: String) {
        if selection.setSelected(value, id: id) { invalidateDraft() }
    }

    func selectAllPlaces(_ selected: Bool) {
        selection.selectAll(selected)
        invalidateDraft()
    }

    func reconcilePlaces(_ places: [Place]) {
        if selection.reconcile(places) { invalidateDraft() }
    }

    func invalidateDraft() {
        cancel()
        needsNewDraft = needsNewDraft || !days.isEmpty
        refinement = ""
        isConfirmingApply = false
        error = nil
    }
    func reset(for trip: TripPlan) {
        cancel()
        days = []
        needsNewDraft = false
        error = nil
        preferences = ""
        processing = .onDevice
        draftProcessing = nil
        revision = nil
        refinement = ""
        isConfirmingApply = false
        pace = .balanced
        focus = .variety
        dayCount = min(max(trip.days.count, 1), TripLimits.planningDays.upperBound)
        selection.reset(trip.savedPlaces)
        refreshAvailability()
    }
}

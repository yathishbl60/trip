import TripLocalization
import TripDomain
import Observation
import Foundation

@MainActor @Observable final class TripAssistantModel {
    var preferences = ""
    var processing = TripAIProcessing.onDevice
    var draftProcessing: TripAIProcessing?
    var dayCount = 3
    var pace = TripPlanningPace.balanced
    var focus = TripPlanningFocus.variety
    let selection = TripAssistantSelection()
    var days: [TripDay] = []
    var needsNewDraft = false
    var isGenerating = false
    var error: String?
    var unavailableReason: String?
    var revision: TripItineraryRevision?
    var refinement = ""
    var isConfirmingApply = false
    @ObservationIgnored private var task: Task<Void, Never>?
    @ObservationIgnored private var generation = 0
    @ObservationIgnored private var deadline: Task<Void, Never>?
    @ObservationIgnored let client: TripAIClient<any ItineraryPlanning>

    init(client: TripAIClient<any ItineraryPlanning>) {
        self.client = client
    }

    var canSaveDraft: Bool { !days.isEmpty && !isGenerating && !needsNewDraft }
    var canGenerate: Bool { unavailableReason == nil && !selection.selectedIDs.isEmpty && !isGenerating }
    var dayCountText: String { TripText.dayCount(dayCount).text }
    var planningPreferences: String {
        "\(pace.prompt) \(focus.prompt) User preferences: \(preferences)\n\(refinementContext)"
    }

    func generate(from trip: TripPlan) {
        cancel()
        refreshAvailability()
        reconcilePlaces(trip.savedPlaces)
        guard canGenerate else { return }
        revision = TripItineraryRevision(trip)
        needsNewDraft = !days.isEmpty
        let token = generation
        let places = selection.selectedPlaces
        let preferences = planningPreferences
        let dayCount = dayCount
        error = nil
        isGenerating = true
        startDeadline(token)
        task = Task {
            await produce(places, preferences: preferences, count: dayCount, token: token)
        }
    }

    private func produce(_ places: [Place], preferences: String, count: Int, token: Int) async {
        do {
            let service = client.makeService(processing)
            let result = try await service.generate(places: places, preferences: preferences, dayCount: count)
            guard token == generation, !Task.isCancelled else { return }
            days = result
            draftProcessing = processing
            needsNewDraft = false
        } catch {
            guard token == generation, !Task.isCancelled else { return }
            self.error = generationMessage(for: error)
        }
        if token == generation { isGenerating = false; deadline?.cancel() }
    }

    func cancel() {
        generation += 1
        deadline?.cancel()
        deadline = nil
        task?.cancel()
        task = nil
        isGenerating = false
    }

    private func startDeadline(_ token: Int) {
        deadline = Task { [weak self] in
            try? await Task.sleep(for: .seconds(60))
            guard let self, !Task.isCancelled, token == generation else { return }
            cancel()
            error = TripText.theDraftTookTooLongTryFewerPlacesOr.text
        }
    }

}

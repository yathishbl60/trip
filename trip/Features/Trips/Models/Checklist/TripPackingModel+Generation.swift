import TripLocalization
import Foundation
import TripDomain

extension TripPackingModel {
    func generate(_ plan: TripPlan) {
        cancel()
        refresh(plan)
        refreshAvailability()
        guard unavailableReason == nil, let context else { return }
        let token = generation
        let preferences = preferences
        error = nil
        isGenerating = true
        startDeadline(token)
        task = Task { [weak self] in
            await self?.produce(context, preferences: preferences, token: token)
        }
    }

    private func produce(_ context: TripPackingContext, preferences: String, token: Int) async {
        do {
            let service = client.makeService(.onDevice)
            let titles = try await service.suggestions(for: context, preferences: preferences)
            guard token == generation, !Task.isCancelled else { return }
            suggestions = TripChecklistEditing.missing(titles, from: existingItems).map(TripPackingSuggestion.init)
            selected = Set(suggestions.map(\.id))
            if suggestions.isEmpty { error = TripText.theseSuggestionsAreAlreadyOnYourChecklistTryA.text }
        } catch {
            guard token == generation, !Task.isCancelled else { return }
            self.error = client.failureMessage(error)
        }
        if token == generation { isGenerating = false; deadline?.cancel() }
    }

    private func startDeadline(_ token: Int) {
        deadline = Task { [weak self] in
            try? await Task.sleep(for: .seconds(45))
            guard let self, !Task.isCancelled, token == generation else { return }
            cancel()
            error = TripText.packingSuggestionsTookTooLongTryAgainOrUse.text
        }
    }
}

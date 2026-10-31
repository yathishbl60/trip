import TripLocalization
import Foundation
import TripDomain

extension TripLookupModel {
    func refreshAvailability() {
        unavailableReason = client.availability(processing)
    }

    func setProcessing(_ value: TripAIProcessing) {
        guard processing != value else { return }
        cancel()
        processing = value
        error = nil
        refreshAvailability()
    }

    func ask() {
        refreshAvailability()
        guard canAsk, let plan else { return }
        cancel()
        error = nil
        isSearching = true
        let token = generation
        let question = question
        task = Task { await search(question, plan: plan, token: token) }
        deadline = Task { [weak self] in
            try? await Task.sleep(for: .seconds(30))
            guard let self, !Task.isCancelled, token == generation else { return }
            cancel()
            error = TripText.thatTookTooLongTryAShorterQuestionOr.text
        }
    }

    private func search(_ question: String, plan: TripSurfacePlan, token: Int) async {
        do {
            let result = try await interpret(question, plan: plan)
            guard token == generation, !Task.isCancelled else { return }
            query = result
            searchText = result.searchText
        } catch {
            guard token == generation, !Task.isCancelled else { return }
            refreshAvailability()
            self.error = unavailableReason ?? failureMessage(error)
        }
        if token == generation { isSearching = false; deadline?.cancel() }
    }

    func failureMessage(_ error: Error) -> String {
        if let failure = error as? TripLookupFailure { return failure.message }
        return client.failureMessage(error)
    }
}

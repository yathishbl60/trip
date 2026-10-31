import TripDomain

extension TripAssistantModel {
    func refreshAvailability() {
        unavailableReason = client.availability(processing)
    }

    func setProcessing(_ value: TripAIProcessing) {
        guard processing != value else { return }
        invalidateDraft()
        processing = value
        refreshAvailability()
    }

    func generationMessage(for error: Error) -> String { client.failureMessage(error) }
}

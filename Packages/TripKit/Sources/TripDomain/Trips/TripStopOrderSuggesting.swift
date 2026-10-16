/// Local ordering exchanges immutable snapshots; callers own review and application.
public nonisolated protocol TripStopOrderSuggesting: Sendable {
    func suggestion(for day: TripDay) async throws -> TripStopOrderProposal
}

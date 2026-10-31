import Foundation
import Observation
import TripDomain

@MainActor @Observable final class TripStopOrderModel: Identifiable {
    let id = UUID()
    let tripID: UUID
    let day: TripDay
    private(set) var proposal: TripStopOrderProposal?
    private(set) var isLoading = false
    var notice: String?
    private(set) var showsOriginal = false
    @ObservationIgnored private let service: any TripStopOrderSuggesting

    init(tripID: UUID, day: TripDay, service: any TripStopOrderSuggesting, proposal: TripStopOrderProposal? = nil) {
        self.service = service
        self.tripID = tripID
        self.day = day
        self.proposal = proposal
    }

    var stops: [TripStop] {
        guard !showsOriginal, let proposal, proposal.hasImprovement else { return day.stops }
        let byID = Dictionary(day.stops.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return proposal.suggestedIDs.compactMap { byID[$0] }
    }

    func showOriginal(_ value: Bool) { showsOriginal = value }

    func load() async {
        guard proposal == nil, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await service.suggestion(for: day)
            try Task.checkCancellation()
            proposal = result
        } catch is CancellationError { return }
        catch { notice = error.localizedDescription }
    }
}

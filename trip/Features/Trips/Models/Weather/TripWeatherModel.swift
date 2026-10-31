import Foundation
import Observation
import TripDomain

@MainActor @Observable final class TripWeatherModel {
    private(set) var request: TripWeatherRequest?
    private(set) var visits: [TripWeatherVisit] = []
    private(set) var attribution: TripWeatherAttribution?
    private(set) var issuedAt: Date?
    private(set) var coverage: DateInterval?
    private(set) var isLoading = false
    private(set) var revision = 0
    var reviewDestination: TripWeatherDestination?
    @ObservationIgnored private var generation = 0
    @ObservationIgnored private var loadingTask: Task<Void, Never>?
    @ObservationIgnored let service: any TripWeatherProviding

    init(service: any TripWeatherProviding) { self.service = service }

    func prepare(trip: TripPlan, day: TripDay) {
        let next = TripWeatherRequest(trip: trip, day: day)
        guard request != next else { return }
        cancel()
        request = next
        visits = []
        attribution = nil
        issuedAt = nil
        coverage = nil
        revision += 1
    }

    func cancel() {
        loadingTask?.cancel()
        loadingTask = nil
        generation += 1
        isLoading = false
    }

    func retry() {
        guard canRefresh else { return }
        revision += 1
    }

    func load() async {
        guard availabilityIssue == nil, let request, !request.visits.isEmpty else { return }
        cancel()
        let generation = generation
        isLoading = true
        let task = Task { await applyForecast(for: request, generation: generation) }
        loadingTask = task
        await withTaskCancellationHandler { await task.value } onCancel: { task.cancel() }
        guard generation == self.generation else { return }
        loadingTask = nil
        isLoading = false
    }

    private func applyForecast(for request: TripWeatherRequest, generation: Int) async {
        let result = await TripWeatherLoader(service: service).load(request)
        guard !Task.isCancelled, generation == self.generation else { return }
        visits = result.visits
        attribution = result.attribution
        issuedAt = result.issuedAt
        coverage = result.coverage
    }
}

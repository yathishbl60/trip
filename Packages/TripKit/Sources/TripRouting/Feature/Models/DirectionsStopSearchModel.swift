#if os(iOS) || os(visionOS)
import Observation
import TripDomain
import Foundation

@MainActor @Observable final class DirectionsStopSearchModel {
    var query = ""
    var results: [Place] = []
    var status = DirectionsSearchStatus.idle
    var isLoading = false
    @ObservationIgnored var generation = 0
    @ObservationIgnored var task: Task<Void, Never>?
    @ObservationIgnored var deadline: Task<Void, Never>?

    func search(_ query: String, environment: DirectionsEnvironment) {
        stop()
        self.query = query
        let search = PlaceSearchQuery(query)
        let text = search.text
        let matches = search.places(in: environment.loadedPlaces() + results)
        results = PlaceSearchResults.unique(matches)
        guard !text.isEmpty else { return }
        isLoading = true
        let generation = generation
        task = Task { await fetch(text, environment: environment, generation: generation) }
        startDeadline()
    }

    private func fetch(_ query: String, environment: DirectionsEnvironment, generation: Int) async {
        do {
            try await Task.sleep(for: .milliseconds(300))
            let places = try await environment.search(query)
            guard !Task.isCancelled, generation == self.generation else { return }
            results = PlaceSearchResults.unique(places + results)
            status = results.isEmpty ? .noResults : .idle
        } catch {
            guard !Task.isCancelled, generation == self.generation else { return }
            status = .unavailable
        }
        if generation == self.generation {
            isLoading = false
            task = nil
            deadline?.cancel()
        }
    }

    private func startDeadline() {
        let generation = generation
        deadline = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(20))
                guard let self, generation == self.generation, !Task.isCancelled else { return }
                stop()
                status = .timedOut
            } catch { /* The search completed or was replaced. */ }
        }
    }

    func reset() {
        stop()
        query = ""
        results = []
    }

    func stop() {
        generation += 1
        task?.cancel()
        deadline?.cancel()
        task = nil
        deadline = nil
        isLoading = false
        status = .idle
    }
}
#endif

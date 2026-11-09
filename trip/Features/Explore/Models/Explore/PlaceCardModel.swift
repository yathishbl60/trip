import MapKit
import Observation
import TripDomain
import TripPlaces

@MainActor @Observable final class PlaceCardModel {
    var item: MKMapItem?
    var hasFailed = false
    private(set) var isLoading = false
    @ObservationIgnored private let provider: any MapItemResolving
    @ObservationIgnored private var task: Task<Void, Never>?
    @ObservationIgnored private var deadline: Task<Void, Never>?
    @ObservationIgnored private var generation = 0

    init(provider: any MapItemResolving = MapItemService()) { self.provider = provider }

    func open(_ place: Place) {
        cancel()
        hasFailed = false
        isLoading = true
        let token = generation
        task = Task { await resolve(place, token: token) }
        deadline = Task { [weak self] in
            try? await Task.sleep(for: .seconds(15))
            guard let self, !Task.isCancelled, generation == token else { return }
            cancel()
            hasFailed = true
        }
    }

    private func resolve(_ place: Place, token: Int) async {
        do {
            let result = try await provider.resolve(place)
            guard !Task.isCancelled, generation == token else { return }
            item = result
        } catch {
            guard !Task.isCancelled, generation == token else { return }
            hasFailed = true
        }
        isLoading = false
        deadline?.cancel()
        deadline = nil
        task = nil
    }

    func cancel() {
        generation += 1
        provider.cancel()
        task?.cancel()
        deadline?.cancel()
        task = nil
        deadline = nil
        isLoading = false
    }
}

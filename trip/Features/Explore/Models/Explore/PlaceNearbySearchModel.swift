import TripLocalization
import Foundation
import MapKit
import Observation
import TripDomain

@MainActor @Observable final class PlaceNearbySearchModel {
    let origin: Place
    private(set) var places: [Place]
    private(set) var isLoading = false
    private(set) var error: String?
    private(set) var retryRevision = 0
    private(set) var category = NearbyPlaceCategory.all
    private var hasLoaded: Bool
    @ObservationIgnored private var generation = 0

    init(origin: Place, results: [Place]? = nil) {
        self.origin = origin
        places = results ?? []
        hasLoaded = results != nil
    }

    func load() async {
        guard !hasLoaded else { return }
        generation += 1
        let token = generation
        isLoading = true
        error = nil
        defer { if token == generation { isLoading = false } }
        do {
            let results = try await fetch()
            guard !Task.isCancelled, token == generation else { return }
            accept(results)
            hasLoaded = true
        } catch {
            guard !Task.isCancelled, token == generation else { return }
            self.error = TripText.couldnTFindNearbyPlacesTryAgain.text
        }
    }

    private func fetch() async throws -> [Place] {
        guard origin.coordinate.isValid else { return [] }
        let region = MKCoordinateRegion(center: origin.coordinate.location,
                                        latitudinalMeters: 2_400, longitudinalMeters: 2_400)
        let category = category
        return try await withThrowingTaskGroup(of: [Place].self) { group in
            group.addTask { try await MapSearchService.nearby(region: region, category: category) }
            group.addTask {
                try await Task.sleep(for: .seconds(15))
                throw URLError(.timedOut)
            }
            defer { group.cancelAll() }
            return try await group.next() ?? []
        }
    }

    private func accept(_ results: [Place]) {
        var seen: Set<String> = [origin.id]
        places = results.filter {
            $0.coordinate.isValid && seen.insert($0.id).inserted
                && $0.coordinate.distance(to: origin.coordinate) <= 2_000
        }.sorted {
            $0.coordinate.distance(to: origin.coordinate) < $1.coordinate.distance(to: origin.coordinate)
        }
    }

    func retry() { retryRevision += 1 }

    func choose(_ category: NearbyPlaceCategory) {
        guard self.category != category else { return }
        generation += 1
        self.category = category
        places = []
        error = nil
        hasLoaded = false
        isLoading = true
        retryRevision += 1
    }
}

nonisolated struct PlaceNearbyRequestID: Hashable {
    let revision: Int
    let isActive: Bool
}

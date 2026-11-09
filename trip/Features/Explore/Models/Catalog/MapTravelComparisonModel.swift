import Foundation
import Observation
import TripDomain
import TripRouting
import TripLocalization

@MainActor @Observable final class MapTravelComparisonModel {
    let places: [Place]
    let groups: [TripSavedPlaceGroup]
    let location = LocationModel()
    var selected: Set<String> = []
    var originID = "current"
    var mode = TravelMode.walking
    var revision = 0
    private(set) var estimates: [String: DirectionsEstimate] = [:]
    private(set) var failures: Set<String> = []
    private(set) var isLoading = false
    private(set) var locationFailure: String?
    @ObservationIgnored let provider: any TravelTimeEstimating
    @ObservationIgnored var cache = MapTravelCache()
    @ObservationIgnored var generation = 0

    init(places: [Place], groups: [TripSavedPlaceGroup], provider: any TravelTimeEstimating = TravelTimeService()) {
        self.places = places
        self.groups = groups
        self.provider = provider
    }

    var origins: [MapTravelOrigin] { MapTravelOrigin.choices(groups: groups, destinations: selected) }
    var chosenPlaces: [Place] { places.filter { selected.contains($0.id) } }
    var request: MapTravelSelection { MapTravelSelection(ids: selected, originID: originID, mode: mode, revision: revision) }

    func toggle(_ place: Place) {
        if selected.contains(place.id) { selected.remove(place.id) }
        else if selected.count < 3 { selected.insert(place.id) }
        if originID != "current", !origins.contains(where: { $0.id == originID }) { originID = "current" }
    }

    func load() async {
        generation += 1
        let token = generation
        location.stop()
        estimates = [:]
        failures = []
        locationFailure = nil
        guard !selected.isEmpty else { isLoading = false; return }
        isLoading = true
        defer { if token == generation { isLoading = false } }
        guard let origin = await resolveOrigin(token: token), !Task.isCancelled, token == generation else { return }
        for place in chosenPlaces {
            guard !Task.isCancelled, token == generation else { return }
            let key = MapTravelKey(origin: origin, destination: place.coordinate, mode: mode)
            if let cached = cache.estimate(for: key) { estimates[place.id] = cached; continue }
            await estimate(place, key: key, token: token)
        }
    }

    private func estimate(_ place: Place, key: MapTravelKey, token: Int) async {
        do {
            let result = try await fetch(key)
            guard !Task.isCancelled, token == generation else { return }
            cache.store(result, for: key)
            estimates[place.id] = result
        } catch {
            guard !Task.isCancelled, token == generation else { return }
            failures.insert(place.id)
        }
    }

    private func resolveOrigin(token: Int) async -> Coordinate? {
        if originID != "current" { return origins.first { $0.id == originID }?.coordinate }
        if let coordinate = location.currentCoordinate { return coordinate }
        location.start()
        defer { if token == generation { location.stop() } }
        for _ in 0..<60 {
            guard !Task.isCancelled, token == generation else { return nil }
            if let coordinate = location.currentCoordinate { return coordinate }
            if !location.isFollowing { break }
            try? await Task.sleep(for: .milliseconds(250))
        }
        if !Task.isCancelled { locationFailure = TripText.chooseSavedOriginOrEnableLocation.text }
        return nil
    }
}

nonisolated struct MapTravelSelection: Hashable {
    let ids: Set<String>
    let originID: String
    let mode: TravelMode
    let revision: Int
}

import Foundation
import MapKit
import Observation
import TripDomain
import TripRouting

@MainActor @Observable final class TripPlanningRoutes {
    private(set) var segments: [TripPlanningSegment] = []
    private(set) var isLoading = false
    private(set) var mode = TravelMode.walking
    @ObservationIgnored let provider: any DirectionsProviding
    @ObservationIgnored var cache: [TripPlanningRouteKey: MKRoute] = [:]
    @ObservationIgnored var generation = 0

    init(provider: any DirectionsProviding = MapDirectionsService()) { self.provider = provider }

    var totalMinutes: Int? {
        guard !isLoading, segments.allSatisfy({ $0.minutes != nil }) else { return nil }
        return segments.reduce(0) { $0 + ($1.minutes ?? 0) }
    }
    var hasMissingRoutes: Bool { segments.contains { $0.minutes == nil } }
    var shortAllowances: Set<UUID> {
        Set(segments.filter { ($0.minutes ?? 0) > $0.end.timing.travelMinutes }.map(\.end.id))
    }

    func selectMode(_ value: TravelMode) {
        guard [.walking, .driving, .cycling].contains(value), mode != value else { return }
        mode = value
        invalidate()
    }

    func invalidate() {
        generation += 1
        provider.cancel()
        isLoading = false
        segments = segments.map { TripPlanningSegment(start: $0.start, end: $0.end, route: nil) }
    }

    func prepare(_ stops: [TripStop]) {
        invalidate()
        segments = zip(stops, stops.dropFirst()).map { start, end in
            let key = TripPlanningRouteKey(start: start.place.coordinate, end: end.place.coordinate, mode: mode)
            return TripPlanningSegment(start: start, end: end, route: cache[key])
        }
    }

    func refreshCache() {
        if !hasMissingRoutes { cache.removeAll(keepingCapacity: true) }
    }

    func load(_ stops: [TripStop]) async {
        prepare(stops)
        let token = generation
        guard hasMissingRoutes else { return }
        isLoading = true
        defer { if generation == token { isLoading = false } }
        do {
            try await Task.sleep(for: .milliseconds(350))
            let result = try await resolve(segments)
            guard generation == token, !Task.isCancelled else { return }
            segments = result
        } catch { return }
    }
}

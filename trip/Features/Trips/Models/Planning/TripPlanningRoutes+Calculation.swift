import Foundation
import MapKit
import TripDomain
import TripRouting

extension TripPlanningRoutes {
    func resolve(_ input: [TripPlanningSegment]) async throws -> [TripPlanningSegment] {
        let token = generation
        let deadline = Task { @MainActor [weak self] in
            try await Task.sleep(for: .seconds(25))
            if self?.generation == token { self?.provider.cancel() }
        }
        defer { deadline.cancel() }
        let started = ContinuousClock.now
        var remainingRequests = 12
        var result: [TripPlanningSegment] = []
        for segment in input {
            guard generation == token, !Task.isCancelled else { throw CancellationError() }
            let route = await resolve(segment, remaining: &remainingRequests, started: started)
            result.append(TripPlanningSegment(start: segment.start, end: segment.end, route: route))
        }
        return result
    }

    private func resolve(_ segment: TripPlanningSegment, remaining: inout Int,
                         started: ContinuousClock.Instant) async -> MKRoute? {
        guard segment.isLocated, !segment.isStationary else { return nil }
        let key = TripPlanningRouteKey(start: segment.start.place.coordinate, end: segment.end.place.coordinate, mode: mode)
        if let cached = cache[key] { return cached }
        guard remaining > 0, started.duration(to: ContinuousClock.now) < .seconds(25) else { return nil }
        remaining -= 1
        guard let route = await request(segment, remaining: &remaining), !Task.isCancelled else { return nil }
        if cache.count >= 256 { cache.removeAll(keepingCapacity: true) }
        cache[key] = route
        return route
    }

    private func request(_ segment: TripPlanningSegment, remaining: inout Int) async -> MKRoute? {
        do { return try await calculate(segment) }
        catch {
            if Task.isCancelled || (error as? MKError)?.code == .loadingThrottled { remaining = 0 }
            return nil
        }
    }

    private func calculate(_ segment: TripPlanningSegment) async throws -> MKRoute {
        let point = RouteWaypoint(id: segment.end.place.id, name: segment.end.place.name,
                                  coordinate: segment.end.place.coordinate)
        let plan = try DirectionsPlan(origin: segment.start.place.coordinate, places: [point],
                                      mode: mode, options: DirectionsOptions())
        let response = try await DirectionsCalculation(provider: provider).calculate(plan)
        guard let first = response.first, case .routes(let routes) = first,
              let route = routes.first, route.expectedTravelTime.isFinite,
              route.expectedTravelTime >= 0, route.polyline.pointCount > 1 else { throw DirectionsFailure.unavailable }
        return route
    }
}

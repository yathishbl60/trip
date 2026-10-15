import Testing
import MapKit
import TripDomain
import TripRouting
import Foundation

@MainActor struct RoutingCancellationTests {
    @Test func cancellationPreventsStartingARequest() async throws {
        let provider = RecordingDirectionsProvider()
        let plan = try makePlan(mode: .walking)
        let task = Task { _ = try await DirectionsCalculation(provider: provider).calculate(plan) }
        task.cancel()
        await #expect(throws: CancellationError.self) { try await task.value }
        #expect(provider.destinations.isEmpty)
    }

    @Test func arrivalPlanningStartsAtTheFinalLeg() async throws {
        let provider = RecordingDirectionsProvider()
        let plan = try makePlan(mode: .driving, arriveBy: true)
        await #expect(throws: DirectionsFailure.self) {
            _ = try await DirectionsCalculation(provider: provider).calculate(plan)
        }
        #expect(provider.destinations == ["Destination"])
    }

    @Test(arguments: [TravelMode.transit, .walking])
    func transitUsesETAAndWalkingUsesRoutes(_ mode: TravelMode) async throws {
        let provider = RecordingDirectionsProvider()
        let plan = try makePlan(mode: mode)
        await #expect(throws: DirectionsFailure.self) {
            _ = try await DirectionsCalculation(provider: provider).calculate(plan)
        }
        #expect(provider.etaOnly == (mode == .transit))
    }

    private func makePlan(mode: TravelMode, arriveBy: Bool = false) throws -> DirectionsPlan {
        var options = DirectionsOptions()
        options.timing = arriveBy ? .arriveBy : .now
        options.date = .now.addingTimeInterval(3_600)
        let places = [RouteWaypoint(id: "stop", name: "Stop", coordinate: .bangkok),
                      RouteWaypoint(id: "destination", name: "Destination", coordinate: Coordinate(latitude: 14, longitude: 101))]
        return try DirectionsPlan(origin: Coordinate(latitude: 13, longitude: 100), places: places, mode: mode, options: options)
    }
}

@MainActor private final class RecordingDirectionsProvider: DirectionsProviding {
    var destinations: [String] = []
    var etaOnly = false

    func calculate(_ request: MKDirections.Request, etaOnly: Bool) async throws -> DirectionsResponse {
        destinations.append(request.destination?.name ?? "")
        self.etaOnly = etaOnly
        throw DirectionsFailure.unavailable
    }

    func cancel() {}
}

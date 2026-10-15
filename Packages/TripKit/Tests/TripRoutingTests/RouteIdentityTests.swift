import Testing
import MapKit
import Foundation
import TripDomain
@testable import TripRouting

@MainActor struct RouteIdentityTests {
    @Test func trafficUpdatesKeepIdentityAndGeometryChangesReplaceIt() {
        let original = route(duration: 60)
        let updated = route(duration: 120)
        let alternative = route(duration: 60, offset: 0.01)
        #expect(original.id == updated.id)
        #expect(original.id != alternative.id)
    }

    @Test func labelPositionsClampIndicesWithoutCrashing() {
        let route = route(duration: 60)
        #expect(route.labelCoordinate(index: -1).isValid)
        #expect(route.labelCoordinate(index: 200).isValid)
    }

    @Test func arrivalHasAnExplicitDisplayState() {
        let estimate = DirectionsEstimate(travelTime: 0, distance: 0, arrival: .now)
        #expect(estimate.durationText == "Arrived")
        #expect(!estimate.arrivalText.isEmpty)
    }

    private func route(duration: TimeInterval, offset: Double = 0) -> DirectionsRoute {
        let coordinates = [Coordinate(latitude: 13.74, longitude: 100.52).location,
                           Coordinate(latitude: 13.75 + offset, longitude: 100.53).location]
        let estimate = DirectionsEstimate(travelTime: duration, distance: 1_000, arrival: .now)
        return DirectionsRoute(name: "Route", estimate: estimate,
            polyline: MKPolyline(coordinates: coordinates, count: coordinates.count),
            steps: [], notices: [], hasTolls: false, hasHighways: false)
    }
}

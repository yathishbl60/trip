import Testing
import Foundation
import MapKit
import TripDomain
@testable import TripRouting

@MainActor struct RoutingContractsTests {
    let origin = Coordinate(latitude: 13.74, longitude: 100.52)
    let stop = RouteWaypoint(id: "stop", name: "Coffee", coordinate: Coordinate(latitude: 13.741, longitude: 100.53))
    let destination = RouteWaypoint(id: "destination", name: "Market", coordinate: .bangkok)

    @Test func orderedLegsPreserveTheRequestedStops() throws {
        let plan = try DirectionsPlan(origin: origin, places: [stop, destination], mode: .walking, options: .init())
        #expect(plan.requests.count == 2)
        #expect(plan.requests[0].source?.location.coordinate.latitude == origin.latitude)
        #expect(plan.requests[0].destination?.name == "Coffee")
        #expect(plan.requests[1].source?.location.coordinate.longitude == stop.coordinate.longitude)
        #expect(plan.requests[1].destination?.name == "Market")
        #expect(plan.requests.allSatisfy { $0.transportType == .walking && $0.requestsAlternateRoutes })
    }

    @Test func arrivalAndAvoidanceAreAppliedWithoutDeparture() throws {
        var options = DirectionsOptions()
        options.timing = .arriveBy
        options.date = Date.now.addingTimeInterval(3_600)
        options.avoidsTolls = true
        options.avoidsHighways = true
        let plan = try DirectionsPlan(origin: origin, places: [destination], mode: .driving, options: options)
        let request = try #require(plan.requests.first)
        #expect(request.arrivalDate == options.date)
        #expect(request.departureDate == nil)
        #expect(request.tollPreference == .avoid && request.highwayPreference == .avoid)
    }

    @Test func rejectsMissingInvalidAndPastRequests() {
        #expect(throws: DirectionsFailure.self) {
            try DirectionsPlan(origin: nil, places: [destination], mode: .driving, options: .init())
        }
        #expect(throws: DirectionsFailure.self) {
            try DirectionsPlan(origin: origin, places: [], mode: .driving, options: .init())
        }
        var options = DirectionsOptions()
        options.timing = .departAt
        options.date = .distantPast
        #expect(throws: DirectionsFailure.self) {
            try DirectionsPlan(origin: origin, places: [destination], mode: .driving, options: options)
        }
    }

    @Test func mapsHandoffPreservesStopOrderAndWalkingPreferences() throws {
        var options = DirectionsOptions()
        options.avoidsBusyRoads = true
        options.avoidsStairs = true
        let link = MapsDirectionsLink(destination: destination.coordinate, stops: [origin, stop.coordinate],
                                      mode: .walking, options: options)
        let url = try #require(link.url)
        let items = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems)
        #expect(items.filter { $0.name == "waypoint" }.map(\.value) == ["13.74,100.52", "13.741,100.53"])
        #expect(items.first { $0.name == "mode" }?.value == "walking")
        #expect(items.first { $0.name == "avoid" }?.value == "busy-roads,stairs")
        #expect(items.allSatisfy { $0.name != "source" })
    }

    @Test func invalidCoordinatesCannotProduceAMapsLink() {
        let invalid = Coordinate(latitude: .nan, longitude: 180)
        #expect(MapsDirectionsLink(destination: invalid, mode: .driving).url == nil)
        #expect(MapsDirectionsLink(destination: origin, stops: [invalid], mode: .walking).url == nil)
    }
}

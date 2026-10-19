#if os(iOS) || os(visionOS)
#if DEBUG
import MapKit
import Foundation
import TripDomain

@MainActor enum DirectionsPreviewFixtures {
    static let longDestination = Place(id: "long", name: "Jaisamand Wildlife Sanctuary and Visitor Centre",
        coordinate: .bangkok, category: .park, importance: 1, rating: nil, reviews: nil)
    static let destination = Place(id: "destination", name: "Jodd Fairs", coordinate: .bangkok,
        category: .shopping, importance: 1, rating: nil, reviews: nil)

    static let stop = Place(id: "stop", name: "Coffee stop", coordinate: Coordinate(latitude: 13.741, longitude: 100.53),
        category: .cafe, importance: 1, rating: nil, reviews: nil)

    static func ready() -> DirectionsModel {
        let model = DirectionsModel()
        model.canCalculate = false
        model.destination = destination
        model.startingPoint.reset(authorized: true, coordinate: Coordinate(latitude: 13.74, longitude: 100.52))
        model.routes = [route(alternate: false), route(alternate: true)]
        model.selectedID = model.routes.first?.id
        model.status = .ready
        model.environment.loadedPlaces = { [stop] }
        model.environment.locationAuthorized = { true }
        return model
    }

    static func withoutLocation() -> DirectionsModel {
        let model = ready()
        model.startingPoint.reset()
        model.environment.locationAuthorized = { false }
        model.clearResults()
        model.status = .choosingOrigin
        return model
    }

    static func unavailable() -> DirectionsModel {
        let model = ready()
        model.clearResults()
        model.status = .unavailable("Directions are not available between these locations.")
        return model
    }

    static func compact() -> DirectionsModel {
        let model = ready()
        model.presentation.detent = model.presentation.compact
        return model
    }

    private static func route(alternate: Bool) -> DirectionsRoute {
        let offset = alternate ? 0.003 : 0.0
        let coordinates = [Coordinate(latitude: 13.74, longitude: 100.52).location,
            Coordinate(latitude: 13.745 + offset, longitude: 100.52).location,
            Coordinate(latitude: 13.745 + offset, longitude: 100.535).location, Coordinate.bangkok.location]
        let estimate = DirectionsEstimate(travelTime: alternate ? 4_140 : 4_380, distance: 5_100,
                                          arrival: Date(timeIntervalSince1970: 1_790_771_700))
        return DirectionsRoute(name: alternate ? "Alternate local preview" : "Suggested local preview", estimate: estimate,
            polyline: MKPolyline(coordinates: coordinates, count: coordinates.count),
            steps: [DirectionsStep(id: 0, instruction: "Turn right onto the main road", distance: 300)],
            notices: ["Sample route for previews"], hasTolls: false, hasHighways: false)
    }
}
#endif
#endif

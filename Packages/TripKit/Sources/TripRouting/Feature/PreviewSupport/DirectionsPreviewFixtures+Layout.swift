#if os(iOS) || os(visionOS)
#if DEBUG
import Foundation

extension DirectionsPreviewFixtures {
    static func tollRoutes() -> DirectionsModel {
        let model = ready()
        let estimate = DirectionsEstimate(travelTime: 17 * 60, distance: 8_530,
                                          arrival: Date(timeIntervalSince1970: 1_792_242_060))
        model.routes = model.routes.enumerated().map { index, route in
            DirectionsRoute(name: route.name, estimate: estimate, polyline: route.polyline,
                            steps: route.steps, notices: route.notices,
                            hasTolls: index == 0, hasHighways: false)
        }
        model.selectedID = model.routes.first?.id
        return model
    }
}
#endif
#endif

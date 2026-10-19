#if os(iOS) || os(visionOS)
import MapKit
import SwiftUI
import TripDomain
#if !TRIP_STANDALONE
import TripLocalization
#endif

public struct DirectionsMapContent: MapContent {
    let controller: DirectionsController
    let scale: CGFloat

    init(controller: DirectionsController, scale: CGFloat) {
        self.controller = controller
        self.scale = scale
    }

    public init(model: DirectionsModel, scale: CGFloat) {
        controller = DirectionsController(model: model)
        self.scale = scale
    }

    public var body: some MapContent {
        ForEach(controller.directions.routes) { route in
            if route.id != controller.directions.selectedID {
                MapPolyline(route.polyline).stroke(appearance.route.opacity(0.6), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .mapOverlayLevel(level: .aboveRoads)
            }
        }
        if let route = controller.directions.selectedRoute {
            MapPolyline(route.polyline).stroke(appearance.route.opacity(0.3), style: StrokeStyle(lineWidth: 11, lineCap: .round))
                .mapOverlayLevel(level: .aboveRoads)
            MapPolyline(route.polyline).stroke(appearance.route.opacity(controller.model.isLoading ? 0.7 : 1), style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .mapOverlayLevel(level: .aboveRoads)
        }
        labels
        ForEach(controller.directions.annotatedPlaces) { place in
            Marker(place.name, systemImage: place.category.symbol, coordinate: place.coordinate.location)
                .tint(controller.model.environment.placeTint(place)).tag(place.id)
        }
    }

    private var appearance: DirectionsAppearance { controller.model.environment.appearance }

    private var labels: some MapContent {
        ForEach(Array(controller.directions.routes.enumerated()), id: \.element.id) { index, route in
            Annotation(route.estimate.durationText, coordinate: route.labelCoordinate(index: index).location, anchor: .center) {
                Button { controller.select(route.id) } label: {
                    DirectionsRouteLabel(route: route, label: controller.directions.label(for: route),
                                         isSelected: route.id == controller.directions.selectedID, appearance: appearance)
                        .scaleEffect(scale)
                }
                .buttonStyle(.plain).disabled(controller.model.status != .ready)
                .accessibilityLabel(controller.directions.choiceLabel(for: route))
                .accessibilityValue("\(route.estimate.durationText), \(route.estimate.distanceText)")
                .accessibilityHint(TripText.showsThisRouteOnTheMap.resource)
            }
            .annotationTitles(.hidden)
        }
    }
}

#if DEBUG
#Preview("Directions map · local alternative routes") {
    Map { DirectionsMapContent(controller: DirectionsController(model: DirectionsPreviewFixtures.ready()), scale: 1) }
}
#Preview("Directions map · searched origin, dark") {
    let model = DirectionsPreviewFixtures.tollRoutes()
    model.startingPoint.selection = .place(DirectionsPreviewFixtures.stop)
    return Map { DirectionsMapContent(model: model, scale: 1) }.preferredColorScheme(.dark)
}
#endif
#endif

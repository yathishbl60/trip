import TripRouting
import TripDomain
import SwiftUI

/// Side effects observe their own inputs without invalidating the map's parent.
struct MapStateSynchronization: ViewModifier {
    let controller: MapController
    @ScaledMetric(relativeTo: .caption) private var markerScale = 1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .sensoryFeedback(.selection, trigger: controller.model.selectedPlace?.id) { _, selected in selected != nil }
            .onChange(of: markerScale, initial: true) { updateAccessibility() }
            .onChange(of: reduceMotion) { updateAccessibility() }
            .onChange(of: controller.model.location.currentCoordinate) { locationChanged() }
            .onChange(of: controller.model.location.status) { locationChanged() }
            .onChange(of: controller.model.location.isFollowing) { locationChanged() }
            .onChange(of: controller.model.directions.revision) {
                ExploreDirectionsController(model: controller.model).updated()
            }
    }

    private func updateAccessibility() {
        controller.accessibility(scale: markerScale, reduceMotion: reduceMotion)
    }

    private func locationChanged() {
        LocationController(model: controller.model).changed()
    }
}

#if DEBUG
#Preview("Map synchronization · local places") {
    ExploreMapView(controller: MapController(model: PreviewFixtures.explore()))
}
#Preview("Map synchronization · large text, animations disabled") {
    ExploreMapView(controller: MapController(model: PreviewFixtures.mapWithoutAnimations()))
        .dynamicTypeSize(.accessibility3)
}
#endif

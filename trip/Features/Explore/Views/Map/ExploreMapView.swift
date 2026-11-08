import TripRouting
import MapEngine
import TripDomain
import MapKit
import SwiftUI

struct ExploreMapView: View {
    let controller: MapController
    @Namespace private var mapScope

    var body: some View {
        mapReader
            .modifier(MapStateSynchronization(controller: controller))
    }

    private var mapReader: some View {
        MapReader { proxy in
            map(proxy)
                .toolbar {
                    ExploreMapTrackingToolbar(showsLocation: controller.model.configuration.showsLocation,
                                              scope: mapScope)
                }
                .onAppear { controller.model.requestProjection() }
                .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .global) }, action: controller.resize)
                .onGeometryChange(for: [CGRect].self, of: MapReservedRegions.frames, action: controller.reservedRegionsChanged)
                .onChange(of: controller.model.layout.projectionRevision, initial: true) { controller.refresh(using: proxy) }
        }
        .mapScope(mapScope)
    }

    private func map(_ proxy: MapProxy) -> some View {
        Map(position: controller.position, interactionModes: .all,
            selection: PlaceController(model: controller.model).mapSelection, scope: mapScope) {
            DirectionsMapContent(model: controller.model.directions, scale: controller.model.camera.markerScale)
            PlaceAnnotations(model: controller.model.layout, controller: PlaceController(model: controller.model),
                             excludedIDs: controller.model.directions.placeIDs)
            if controller.model.configuration.showsLocation { UserAnnotation() }
        }
        .mapStyle(controller.model.appearance.mapStyle)
        .mapControls {
            MapCompass(scope: mapScope).controlSize(.regular)
            MapScaleView(scope: mapScope)
        }
        .onMapCameraChange(frequency: .continuous) { controller.changed($0, proxy: proxy) }
        .onMapCameraChange(frequency: .onEnd) { controller.settled($0, proxy: proxy) }
    }
}

#if DEBUG
#Preview("Close · detailed views") {
    ExploreMapView(controller: MapController(model: PreviewFixtures.explore(.street)))
}
#Preview("Medium · icons and images") {
    ExploreMapView(controller: MapController(model: PreviewFixtures.explore(.district)))
}
#Preview("Overview · dots") {
    ExploreMapView(controller: MapController(model: PreviewFixtures.explore(.region)))
}
#Preview("Dark street") {
    ExploreMapView(controller: MapController(model: PreviewFixtures.explore(.street)))
        .preferredColorScheme(.dark)
}
#Preview("Dense collection · 2,000 local places") {
    ExploreMapView(controller: MapController(model: PreviewFixtures.dense()))
}
#Preview("Street · accessibility text") {
    ExploreMapView(controller: MapController(model: PreviewFixtures.explore(.street)))
        .dynamicTypeSize(.accessibility3)
}
#Preview("Dense zoom · landscape", traits: .landscapeLeft) {
    ExploreMapView(controller: MapController(model: PreviewFixtures.dense()))
}
#Preview("Dense zoom · accessibility text") {
    ExploreMapView(controller: MapController(model: PreviewFixtures.dense()))
        .dynamicTypeSize(.accessibility3)
}
#endif

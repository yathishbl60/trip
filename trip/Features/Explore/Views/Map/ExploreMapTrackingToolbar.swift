import MapKit
import SwiftUI

struct ExploreMapTrackingToolbar: ToolbarContent {
    let showsLocation: Bool
    let scope: Namespace.ID

    var body: some ToolbarContent {
        ToolbarItem(id: "map.user-location", placement: .topBarLeading) {
            if showsLocation {
                MapUserLocationButton(scope: scope).controlSize(.regular)
            }
        }
        #if os(iOS)
        .axisBehavior(.verticalPreferred)
        #endif
    }
}

#if DEBUG
#Preview("Tracking toolbar · adaptive map") {
    let controller = MapController(model: PreviewFixtures.explore())
    return NavigationStack {
        ExploreMapView(controller: controller)
            .toolbar { ExploreToolbar(controller: controller) }
    }
}
#Preview("Tracking toolbar · landscape", traits: .landscapeLeft) {
    let controller = MapController(model: PreviewFixtures.explore())
    return NavigationStack {
        ExploreMapView(controller: controller)
            .toolbar { ExploreToolbar(controller: controller) }
    }
}
#endif

import SwiftUI
import TripDomain
import CoreGraphics

/// Keep the results List at the root of one stack so native Back preserves scrolling.
struct MapBrowseNavigation<Detail: View>: View {
    let controller: MapBrowseController
    @ViewBuilder let detail: (Place, PlaceController) -> Detail

    var body: some View {
        let revision = controller.model.selection.revision
        let placeID = controller.model.selectedPlace?.id
        NavigationStack(path: controller.path) {
            MapBrowseView(controller: controller)
                .navigationDestination(for: PlaceDetailDestination.self, destination: destination)
        }
        .onGeometryChange(for: BrowsePanelMeasurement.self) {
            BrowsePanelMeasurement(frame: $0.frame(in: .global), placeID: placeID, revision: revision)
        } action: {
            controller.panelChanged($0.frame, placeID: $0.placeID, revision: $0.revision)
        }
    }

    @ViewBuilder private func destination(_ destination: PlaceDetailDestination) -> some View {
        let places = PlaceController(model: controller.model)
        switch destination {
        case .detail(let place): detail(place, places)
        case .nearby(let items): NearbyPlacesView(controller: places, places: items)
        case .search(let origin): PlaceNearbySearchView(origin: origin, controller: places)
        }
    }
}

private nonisolated struct BrowsePanelMeasurement: Equatable {
    let frame: CGRect
    let placeID: String?
    let revision: Int
}

#if DEBUG
#Preview("Browse → details → Back · retained list") {
    MapBrowseNavigation(controller: MapBrowseController(model: MapBrowsePreviewFixtures.loaded())) {
        PlaceDetailView(place: $0, controller: $1)
    }
}
#endif

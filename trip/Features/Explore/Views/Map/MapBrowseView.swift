import CoreGraphics
import SwiftUI
import TripLocalization

struct MapBrowseView: View {
    let controller: MapBrowseController

    var body: some View {
        let revision = controller.model.selection.revision
        NavigationStack {
            results
            .navigationTitle(TripText.placesInThisArea.resource).navigationBarTitleDisplayMode(.inline)
            .toolbar { MapBrowseToolbar(controller: controller) }
        }
        .onGeometryChange(for: MapBrowseMeasurement.self) { MapBrowseMeasurement(frame: $0.frame(in: .global), revision: revision) }
            action: { controller.areaChanged($0.frame, revision: $0.revision) }
    }

    private var results: some View {
        List {
            status
            Section {
                ForEach(controller.model.browse.items) { MapBrowseRow(item: $0, controller: controller) }
            } header: {
                Text(TripText.placeCount(controller.model.browse.items.count).resource)
                if !controller.model.catalog.query.isEmpty { Text(controller.model.catalog.query) }
            }
        }
        .scrollContentBackground(.hidden)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
    }

    @ViewBuilder private var status: some View {
        if controller.model.browse.isRefreshing || controller.model.catalog.isSearching
            || (!controller.model.browse.hasLoaded && controller.model.browse.canResolveArea) {
            ProgressView(TripText.searching.resource)
        }
        if !controller.model.catalog.status.isEmpty {
            Text(controller.model.catalog.status).foregroundStyle(.secondary)
            if controller.model.catalog.canRetrySearch {
                Button(TripText.tryAgain.resource) { CatalogController(model: controller.model).search() }
            }
        }
        if controller.model.browse.items.isEmpty, !controller.model.browse.isRefreshing,
           !controller.model.catalog.isSearching, controller.model.browse.hasLoaded || !controller.model.browse.canResolveArea {
            ContentUnavailableView(TripText.noPlacesNearby.resource, systemImage: "mappin.slash",
                description: Text(controller.model.browse.canResolveArea
                    ? TripText.tryAnotherNameOrMoveTheMap.resource : TripText.zoomInForAreaList.resource))
        }
    }
}

private nonisolated struct MapBrowseMeasurement: Equatable {
    let frame: CGRect
    let revision: Int
}

#if DEBUG
#Preview("Map results · loaded places and saved visit") {
    MapBrowseView(controller: MapBrowseController(model: MapBrowsePreviewFixtures.loaded()))
}
#Preview("Map results · empty, local") {
    MapBrowseView(controller: MapBrowseController(model: MapBrowsePreviewFixtures.loaded(empty: true)))
}
#Preview("Map results · large text, offline") {
    MapBrowseView(controller: MapBrowseController(model: PreviewFixtures.offline()))
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

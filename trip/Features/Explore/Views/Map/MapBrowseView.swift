import CoreGraphics
import SwiftUI
import TripLocalization

struct MapBrowseView: View {
    let controller: MapBrowseController

    var body: some View {
        results
            .navigationTitle(TripText.placesInThisArea.resource).navigationBarTitleDisplayMode(.inline)
            .toolbar { MapBrowseToolbar(controller: controller) }
            .navigationDestination(isPresented: controller.comparison) {
                MapTravelComparisonView(model: controller.comparisonModel())
            }
    }

    private var results: some View {
        List {
            status
            Section {
                ForEach(controller.model.browse.items) { MapBrowseRow(item: $0, controller: controller) }
            } header: {
                count
                if controller.model.savedMap.isActive { Text(SavedMapController(model: controller.model).title) }
                if !controller.model.catalog.query.isEmpty { Text(controller.model.catalog.query) }
            }
        }
        .scrollContentBackground(.hidden)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
    }

    @ViewBuilder private var status: some View {
        if controller.model.browse.items.isEmpty, isLoading {
            ProgressView(TripText.searching.resource)
        }
        if !controller.model.discoveryStatus.isEmpty {
            Text(controller.model.discoveryStatus).foregroundStyle(.secondary)
            if controller.model.catalog.canRetrySearch {
                Button(TripText.tryAgain.resource) { CatalogController(model: controller.model).search() }
            }
        }
        if controller.model.browse.items.isEmpty, !controller.model.browse.isRefreshing,
           !controller.model.discoveryIsSearching, controller.model.browse.hasLoaded || !controller.model.browse.canResolveArea {
            empty
        }
    }

    private var isLoading: Bool {
        controller.model.browse.isRefreshing || controller.model.discoveryIsSearching
            || (!controller.model.browse.hasLoaded && controller.model.browse.canResolveArea)
    }

    private var count: some View {
        HStack {
            Text(TripText.placeCount(controller.model.browse.items.count).resource)
            Spacer()
            ProgressView().controlSize(.small).opacity(isLoading && !controller.model.browse.items.isEmpty ? 1 : 0)
                .accessibilityHidden(true)
        }
    }

    private var empty: some View {
        ContentUnavailableView {
            Label(controller.model.savedMap.isActive ? TripText.noSavedPlacesInArea.resource : TripText.noPlacesNearby.resource,
                  systemImage: "mappin.slash")
        } description: {
            Text(controller.model.browse.canResolveArea
                 ? TripText.tryAnotherNameOrMoveTheMap.resource : TripText.zoomInForAreaList.resource)
        } actions: {
            if controller.model.savedMap.isActive {
                Button(TripText.showAllPlaces.resource) { SavedMapController(model: controller.model).scope.wrappedValue = .all }
            }
        }
    }
}

#if DEBUG
#Preview("Map results · loaded places and saved visit") {
    NavigationStack { MapBrowseView(controller: MapBrowseController(model: MapBrowsePreviewFixtures.loaded())) }
}
#Preview("Map results · empty, local") {
    NavigationStack { MapBrowseView(controller: MapBrowseController(model: MapBrowsePreviewFixtures.loaded(empty: true))) }
}
#Preview("Map results · large text, offline") {
    MapBrowseView(controller: MapBrowseController(model: PreviewFixtures.offline()))
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

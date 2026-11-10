import TripLocalization
import SwiftUI
import TripDomain

/// One destination inside the sheet's navigation stack; it never presents another sheet root.
struct PlaceDetailContentView: View {
    let place: Place
    let controller: PlaceController
    @State private var lookAround = PlaceLookAroundModel()

    var body: some View {
        content
        .listStyle(.insetGrouped).scrollContentBackground(.hidden)
        .contentMargins(.top, AppTheme.Spacing.small, for: .scrollContent)
        .listSectionSpacing(.compact)
        .modifier(PlacePanelContentVisibility(isCompact: controller.model.selection.presentation.isCompact))
        .navigationTitle(controller.model.selection.presentation.isCompact ? place.name : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { PlaceDetailToolbar(place: place, controller: controller) }
        .modifier(PlaceLookAroundPresentation(coordinate: place.coordinate, model: lookAround))
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
    }

    private var content: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: AppTheme.spacing) {
                    PlaceDetailInformationView(place: place)
                    PlaceActionsView(place: place, controller: controller)
                }
                .listRowBackground(Color.clear).listRowSeparator(.hidden)
            }
            PlaceDetailContactSection(place: place)
            exploration
        }
    }

    private var exploration: some View {
        Section {
            PlaceDetailPhotoView(place: place)
            PlaceLookAroundView(place: place, model: lookAround)
            Button(TripText.viewIn3D.resource, systemImage: "cube") { controller.exploreIn3D(place) }
            Button(place.nearbyTitle, systemImage: "sparkle.magnifyingglass") { controller.discoverNearby(place) }
            if controller.model.selection.canChooseNearby {
                Button(TripText.otherPlacesHere.resource, systemImage: "mappin.and.ellipse") {
                    controller.showNearbyPlaces(place)
                }.badge(controller.model.selection.nearbyPlaces.count - 1)
            }
        } header: { Text(TripText.explore.resource) }
    }
}

#if DEBUG
#Preview("Place content · live information") {
    NavigationStack {
        PlaceDetailContentView(place: PlaceDetailPreviewFixtures.live,
                               controller: PlaceController(model: PreviewFixtures.explore()))
    }
}
#Preview("Place content · long title, large text") {
    NavigationStack {
        PlaceDetailContentView(place: PreviewFixtures.longName,
                               controller: PlaceController(model: PreviewFixtures.explore()))
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

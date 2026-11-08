import TripLocalization
import SwiftUI
import TripDomain

struct NearbyPlacesView: View {
    let controller: PlaceController
    let places: [Place]

    var body: some View {
        List {
            Section {
                ForEach(places, content: choice)
            }
        }
        .navigationTitle(TripText.placesHere.resource)
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .modifier(PlacePanelContentVisibility(isCompact: controller.model.selection.presentation.isCompact))
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
    }

    private func choice(_ place: Place) -> some View {
        Button { controller.selectNearby(place) } label: {
            HStack(spacing: AppTheme.Spacing.small) {
                PlaceChoiceRow(place: place)
                if controller.model.selectedPlace?.id == place.id {
                    Image(systemName: "checkmark").foregroundStyle(.tint).accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(controller.model.selectedPlace?.id == place.id ? .isSelected : [])
    }
}

#if DEBUG
#Preview("Coincident annotations · choose either place") {
    let model = PreviewFixtures.explore()
    model.select(PreviewFixtures.hotel)
    model.selection.nearbyPlaces = [PreviewFixtures.hotel, PreviewFixtures.unrated, PreviewFixtures.longName]
    return NavigationStack { NearbyPlacesView(controller: PlaceController(model: model), places: model.selection.nearbyPlaces) }
}
#Preview("Nearby places · large text, dark") {
    let model = PreviewFixtures.explore()
    model.select(PreviewFixtures.longName)
    model.selection.nearbyPlaces = [PreviewFixtures.longName, PlaceDetailPreviewFixtures.live]
    return NavigationStack { NearbyPlacesView(controller: PlaceController(model: model), places: model.selection.nearbyPlaces) }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

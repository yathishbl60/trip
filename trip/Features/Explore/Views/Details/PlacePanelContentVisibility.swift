import SwiftUI

struct PlacePanelContentVisibility: ViewModifier {
    let isCompact: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isCompact ? 0 : 1)
            .allowsHitTesting(!isCompact)
            .accessibilityHidden(isCompact)
    }
}

#if DEBUG
#Preview("Collapsed place card · local selection") {
    @Previewable @State var presented = true
    let model = PreviewFixtures.explore()
    model.select(PreviewFixtures.hotel)
    model.selection.presentation.detent = PlacePresentationModel.compact
    return Color.clear.sheet(isPresented: $presented) {
        PlaceDetailsSheetView(model: model) { place, controller in
            PlaceDetailView(place: place, controller: controller)
        }
    }
}
#Preview("Collapsed nearby detail · retained navigation, local") {
    @Previewable @State var presented = true
    let model = PreviewFixtures.explore()
    model.select(PreviewFixtures.hotel)
    model.selection.nearbyPlaces = [PreviewFixtures.hotel, PreviewFixtures.unrated]
    model.selection.showNearbyPlaces(for: PreviewFixtures.hotel)
    model.selectNearbyPlace(PreviewFixtures.unrated)
    model.selection.presentation.detent = PlacePresentationModel.compact
    return Color.clear.sheet(isPresented: $presented) {
        PlaceDetailsSheetView(model: model) { place, controller in
            PlaceDetailView(place: place, controller: controller)
        }
    }
}
#endif

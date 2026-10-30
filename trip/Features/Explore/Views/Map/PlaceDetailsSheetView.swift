import CoreGraphics
import TripDomain
import SwiftUI

/// One presented sheet updates its content when another annotation is selected.
struct PlaceDetailsSheetView<Detail: View>: View {
    let model: ExploreModel
    private let detail: (Place, PlaceController) -> Detail

    init(model: ExploreModel, @ViewBuilder detail: @escaping (Place, PlaceController) -> Detail) {
        self.model = model
        self.detail = detail
    }

    var body: some View {
        if let place = model.selection.rootPlace, let visiblePlace = model.selectedPlace {
            let revision = model.selection.revision
            detail(place, PlaceController(model: model))
                .id(place.id)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .global) }) {
                    MapController(model: model).detailAreaChanged($0, placeID: visiblePlace.id, revision: revision)
                }
        }
    }
}

#if DEBUG
#Preview("Place details · local selection") {
    let model = PreviewFixtures.explore()
    model.select(PreviewFixtures.hotel)
    return PlaceDetailsSheetView(model: model) { place, controller in
        PlaceDetailView(place: place, controller: controller)
    }
}
#Preview("Switch selection · same sheet") {
    @Previewable @State var model = PreviewFixtures.explore()
    PlaceDetailsSheetView(model: model) { place, controller in
        PlaceDetailView(place: place, controller: controller)
    }
    .onAppear { model.select(PreviewFixtures.hotel) }
    .overlay(alignment: .bottom) {
        Button("Select another place") {
            PlaceController(model: model).select(PreviewFixtures.unrated)
        }.buttonStyle(.borderedProminent).padding()
    }
}
#Preview("Crowded annotation · details first") {
    let model = PreviewFixtures.explore()
    model.select(PreviewFixtures.hotel)
    model.selection.nearbyPlaces = [PreviewFixtures.hotel, PreviewFixtures.unrated, PreviewFixtures.longName]
    return PlaceDetailsSheetView(model: model) { place, controller in
        PlaceDetailView(place: place, controller: controller)
    }
}
#endif

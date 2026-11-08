import TripDomain
import SwiftUI

struct PlaceDetailView: View {
    let place: Place
    let controller: PlaceController

    var body: some View {
        NavigationStack(path: controller.detailPath) {
            PlaceDetailContentView(place: place, controller: controller)
                .navigationDestination(for: PlaceDetailDestination.self, destination: destination)
        }
    }

    @ViewBuilder private func destination(_ destination: PlaceDetailDestination) -> some View {
        switch destination {
        case .detail(let place):
            PlaceDetailContentView(place: place, controller: controller)
        case .nearby(let places):
            NearbyPlacesView(controller: controller, places: places)
        case .search(let origin):
            PlaceNearbySearchView(origin: origin, controller: controller)
        }
    }
}

#if DEBUG
#Preview("Nearby detail · back to list and original place") {
    let model = PreviewFixtures.explore()
    model.select(PreviewFixtures.hotel)
    model.selection.nearbyPlaces = [PreviewFixtures.hotel, PreviewFixtures.unrated]
    model.selection.showNearbyPlaces(for: PreviewFixtures.hotel)
    model.selectNearbyPlace(PreviewFixtures.unrated)
    return PlaceDetailView(place: PreviewFixtures.hotel, controller: PlaceController(model: model))
}
#Preview("Hotel details") {
    PlaceDetailView(place: PreviewFixtures.hotel, controller: PlaceController(model: PlaceDetailPreviewFixtures.saving()))
}
#Preview("Long name · dark") {
    PlaceDetailView(place: PreviewFixtures.longName, controller: PlaceController(model: PreviewFixtures.explore()))
        .preferredColorScheme(.dark)
}
#Preview("Unrated place · accessibility") {
    PlaceDetailView(place: PreviewFixtures.unrated, controller: PlaceController(model: PlaceDetailPreviewFixtures.saving()))
        .dynamicTypeSize(.accessibility2)
}
#Preview("Live place") {
    PlaceDetailView(place: PlaceDetailPreviewFixtures.live,
                    controller: PlaceController(model: PreviewFixtures.explore()))
}
#Preview("Place details · narrow, large text") {
    PlaceDetailView(place: PreviewFixtures.longName,
                    controller: PlaceController(model: PlaceDetailPreviewFixtures.saving()))
        .frame(width: 320).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

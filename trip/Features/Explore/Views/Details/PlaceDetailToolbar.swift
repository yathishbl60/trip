import TripLocalization
import SwiftUI
import TripDomain

struct PlaceDetailToolbar: ToolbarContent {
    let place: Place
    let controller: PlaceController

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if let url = place.mapsURL {
                ShareLink(item: url, preview: SharePreview(place.name)) {
                    Label(TripText.sharePlace.resource, systemImage: "square.and.arrow.up")
                }
            }
            Menu(TripText.moreActions.resource, systemImage: "ellipsis") { actions }
        }
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .close) { controller.dismiss(place) }
        }
    }

    private var actions: some View {
        Group {
            if controller.model.selection.canChooseNearby {
                Button(TripText.otherPlacesHere.resource, systemImage: "mappin.and.ellipse") { controller.showNearbyPlaces(place) }
            }
            Button(place.nearbyTitle, systemImage: "sparkle.magnifyingglass") { controller.discoverNearby(place) }
            Button(TripText.focusOnMap.resource, systemImage: "viewfinder") { controller.focus(place) }
        }
    }
}

#if DEBUG
#Preview("Place menu · all actions") {
    NavigationStack {
        Color.clear.toolbar {
            PlaceDetailToolbar(place: PlaceDetailPreviewFixtures.live,
                               controller: PlaceController(model: PreviewFixtures.explore()))
        }
    }
}
#endif

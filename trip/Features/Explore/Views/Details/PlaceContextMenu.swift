import TripLocalization
import TripDomain
import SwiftUI

struct PlaceContextMenu: View {
    let place: Place
    let controller: PlaceController

    var body: some View {
        Button(TripText.placeDetails.resource, systemImage: "info.circle") { controller.select(place) }
        Button(TripText.directions.resource, systemImage: "arrow.triangle.turn.up.right.diamond") {
            ExploreDirectionsController(model: controller.model).begin(place)
        }
        if controller.model.canSavePlaces {
            Button(TripText.saveToTrip.resource, systemImage: "bookmark") {
                controller.save(place)
            }
        }
        Button(TripText.viewIn3D.resource, systemImage: "cube") { controller.exploreIn3D(place) }
        Button(place.nearbyTitle, systemImage: "sparkle.magnifyingglass") { controller.discoverNearby(place) }
        if let url = place.mapsURL { ShareLink(item: url, preview: SharePreview(place.name)) }
    }
}

#if DEBUG
#Preview("Place quick actions") {
    Menu("Place actions") {
        PlaceContextMenu(place: PreviewFixtures.hotel, controller: PlaceController(model: PreviewFixtures.explore()))
    }
}
#Preview("Place actions · dark") {
    Menu("Place actions") {
        PlaceContextMenu(place: PreviewFixtures.unrated, controller: PlaceController(model: PreviewFixtures.explore()))
    }.preferredColorScheme(.dark)
}
#endif

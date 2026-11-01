import TripLocalization
import SwiftUI
import TripDomain

struct TripMapPlaceActions: View {
    let stop: TripMapStop
    let controller: TripController

    var body: some View {
        Button(TripText.showInExplore.resource, systemImage: "mappin.and.ellipse") { controller.showOnMap(stop.place) }
            .disabled(!stop.place.coordinate.isValid)
        if let url = stop.place.mapsURL, stop.place.coordinate.isValid {
            ShareLink(item: url, preview: SharePreview(stop.place.name))
        }
    }
}

#if DEBUG
#Preview("Place actions · local menu") {
    let model = PreviewFixtures.tripPlanner()
    let map = TripMapModel(tripID: model.library.trips[0].id, initialDayID: nil, library: model.library)
    Menu("Place actions") {
        if let stop = map.stops.first { TripMapPlaceActions(stop: stop, controller: TripController(model: model)) }
    }
}
#endif

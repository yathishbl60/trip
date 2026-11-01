import TripLocalization
import SwiftUI
import MapKit
import TripDomain

struct TripMapCanvas: View {
    let controller: TripMapController

    var body: some View {
        if controller.model.mappedStops.isEmpty {
            ContentUnavailableView(TripText.noPlacesToMap.resource, systemImage: "map",
                description: Text(TripText.chooseAnotherDayOrAddPlacesToYourItinerary.resource))
        } else {
            map
        }
    }

    private var map: some View {
        Map(position: controller.position, selection: controller.selection) {
            ForEach(controller.model.mappedStops) { stop in
                Marker(stop.label, monogram: Text(stop.number, format: .number), coordinate: stop.place.coordinate.location)
                    .tint(AppTheme.accentFill)
                    .tag(stop.id)
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
        .onMapCameraChange(frequency: .continuous) { controller.recordCamera($0.camera) }
        .mapControls {
            MapCompass()
            MapScaleView()
            MapPitchToggle()
        }
        #if os(iOS)
        .backgroundExtensionEffect()
        #endif
    }
}

#if DEBUG
#Preview("Day pins · live map tiles") {
    let model = PreviewFixtures.tripPlanner()
    TripMapCanvas(controller: TripMapController(model: TripMapModel(tripID: model.library.trips[0].id,
        initialDayID: nil, library: model.library)))
}
#Preview("Empty day") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    TripMapCanvas(controller: TripMapController(model: TripMapModel(tripID: trip.id,
        initialDayID: trip.days[1].id, library: model.library)))
}
#endif

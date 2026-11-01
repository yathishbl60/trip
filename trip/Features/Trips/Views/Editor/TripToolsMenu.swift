import TripLocalization
import SwiftUI
import TripDomain

struct TripToolsMenu: View {
    let trip: TripPlan
    let controller: TripController

    var body: some View {
        Group {
            if trip.hasMappedPlaces {
                Button(TripText.map.resource, systemImage: "map") { controller.openDetail(.map, tripID: trip.id) }
            }
            Button(TripText.checklist.resource, systemImage: "checklist") { controller.openDetail(.checklist, tripID: trip.id) }
            Button(TripText.collections.resource, systemImage: "square.stack") { controller.openDetail(.collections, tripID: trip.id) }
            TripNativeTools(trip: trip, controller: controller)
        }
    }
}

#if DEBUG
#Preview("Trip tools · native menu") {
    let model = PreviewFixtures.tripPlanner()
    Menu("Trip options") { TripToolsMenu(trip: model.library.trips[0], controller: TripController(model: model)) }
}
#Preview("Trip tools · accessibility") {
    let model = PreviewFixtures.tripPlanner()
    Menu("Trip options") { TripToolsMenu(trip: model.library.trips[0], controller: TripController(model: model)) }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Shortcut navigation · open, back, reopen, local data") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        TripEditorView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }
}
#endif

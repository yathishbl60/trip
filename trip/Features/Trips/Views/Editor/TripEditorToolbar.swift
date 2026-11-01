import TripLocalization
import TripDomain
import SwiftUI

struct TripEditorToolbar: ToolbarContent {
    let trip: TripPlan
    let controller: TripController

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) { EditButton() }
        ToolbarOverflowMenu {
            TripToolsMenu(trip: trip, controller: controller)
            Divider()
            Button(TripText.askMyTrip.resource, systemImage: "text.magnifyingglass") { controller.openLookup(trip.id) }
            Button(TripText.draftAnItinerary.resource, systemImage: "sparkles") { controller.openAssistant(trip.id) }
            ShareLink(item: trip.shareText, preview: SharePreview(trip.title))
            Button(TripText.editTrip.resource, systemImage: "pencil") { controller.beginEdit(trip.id) }
        }
    }
}

#if DEBUG
#Preview("Trip toolbar") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        Color.clear.toolbar { TripEditorToolbar(trip: model.library.trips[0], controller: TripController(model: model)) }
    }
}
#Preview("Trip toolbar · dark") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        Color.clear.toolbar { TripEditorToolbar(trip: model.library.trips[0], controller: TripController(model: model)) }
    }.preferredColorScheme(.dark)
}
#Preview("Trip toolbar · compact, large text") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        TripEditorView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }.frame(width: 320, height: 480).dynamicTypeSize(.accessibility2)
}
#endif

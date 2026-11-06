import TripLocalization
import SwiftUI
import TripDomain

struct TripMapToolbar: ToolbarContent {
    let controller: TripMapController
    var showsDayPicker = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some ToolbarContent {
        if showsDayPicker {
            ToolbarItem(placement: .topBarTrailing) { TripMapDayPicker(controller: controller) }
                .horizontalToolbarItem()
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button(TripText.showAllPlaces.resource, systemImage: "arrow.up.left.and.arrow.down.right") {
                controller.fit(reduceMotion: reduceMotion)
            }.disabled(controller.model.mappedStops.isEmpty)
        }
    }

}

#if DEBUG
#Preview("Trip map toolbar") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        Color.clear.toolbar {
            TripMapToolbar(controller: TripMapController(model: TripMapModel(tripID: model.library.trips[0].id,
                initialDayID: nil, library: model.library)))
        }
    }
}
#endif

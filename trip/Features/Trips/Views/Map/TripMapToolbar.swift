import TripLocalization
import SwiftUI
import TripDomain

struct TripMapToolbar: ToolbarContent {
    let controller: TripMapController
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            dayMenu
        }.horizontalToolbarItem()
        ToolbarItem(placement: .topBarTrailing) {
            Button(TripText.showAllPlaces.resource, systemImage: "arrow.up.left.and.arrow.down.right") {
                controller.fit(reduceMotion: reduceMotion)
            }.disabled(controller.model.mappedStops.isEmpty)
        }
    }

    private var dayMenu: some View {
        Picker(selection: controller.daySelection(reduceMotion: reduceMotion)) {
            ForEach(controller.model.trip?.days ?? []) { day in
                Text("\(day.title) · \(day.placeCountText)").tag(Optional(day.id))
            }
        } label: { Label(controller.model.day?.title ?? TripText.day.text, systemImage: "calendar") }
        .pickerStyle(.menu)
        .disabled(controller.model.trip == nil)
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

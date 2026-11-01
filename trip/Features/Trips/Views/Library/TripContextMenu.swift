import TripLocalization
import TripDomain
import SwiftUI

struct TripContextMenu: View {
    let trip: TripPlan
    let controller: TripController
    @Environment(\.openWindow) private var openWindow
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows

    var body: some View {
        if supportsMultipleWindows {
            Button(TripText.openInNewWindow.resource, systemImage: "rectangle.badge.plus") {
                openWindow(id: "trip", value: trip.id)
            }
        }
        Button(TripText.editTrip.resource, systemImage: "pencil") { controller.beginEdit(trip.id) }
        Button(TripText.duplicate.resource, systemImage: "square.on.square") { controller.duplicate(trip) }
            .disabled(!controller.model.library.canCreate)
        ShareLink(item: trip.shareText, preview: SharePreview(trip.title))
        Divider()
        Button(TripText.deleteTrip.resource, systemImage: "trash", role: .destructive) { controller.requestDelete(trip.id) }
    }
}

#if DEBUG
#Preview("Trip actions") {
    let model = PreviewFixtures.tripPlanner()
    Menu("Trip actions") { TripContextMenu(trip: model.library.trips[0], controller: TripController(model: model)) }
}
#Preview("Trip actions · dark") {
    let model = PreviewFixtures.tripPlanner()
    Menu("Trip actions") { TripContextMenu(trip: model.library.trips[0], controller: TripController(model: model)) }
        .preferredColorScheme(.dark)
}
#endif

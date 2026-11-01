import SwiftUI
import TripDomain
import TripLocalization

struct TripNativeTools: View {
    let trip: TripPlan
    let controller: TripController

    var body: some View {
        Section {
            Button(TripText.bookingImport.resource, systemImage: "doc.viewfinder") {
                controller.beginBookingImport(tripID: trip.id)
            }.disabled(trip.events.count >= TripLimits.events)
            if controller.supportsSystemExports {
                Button(TripText.exportToCalendar.resource, systemImage: "calendar.badge.plus") {
                    controller.beginCalendarExport(tripID: trip.id)
                }
            }
        }
    }
}

#if DEBUG
#Preview("Native trip services · local data") {
    let model = TripJourneyPreview.planner()
    Menu("Trip options") { TripNativeTools(trip: model.library.trips[0], controller: TripController(model: model)) }
}
#endif

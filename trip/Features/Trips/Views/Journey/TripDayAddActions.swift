import TripLocalization
import SwiftUI
import TripDomain

struct TripDayAddActions: View {
    let day: TripDay
    let trip: TripPlan
    let controller: TripController
    var includesPlaces = true

    var body: some View {
        if includesPlaces {
            Button(TripText.places.resource, systemImage: "mappin.and.ellipse") {
                controller.beginSavedPlaces(dayID: day.id, tripID: trip.id)
            }.disabled(day.stops.count >= TripLimits.stops)
        }
        Section {
            Button(TripText.bookingImport.resource, systemImage: "doc.viewfinder") {
                controller.beginBookingImport(tripID: trip.id, dayID: day.id)
            }.disabled(trip.events.count >= TripLimits.events)
            eventActions
        }
    }

    private var eventActions: some View {
        ForEach(TripEventKind.allCases, id: \.self) { kind in
            Button(kind.title, systemImage: kind.symbol) {
                controller.beginEvent(dayID: day.id, tripID: trip.id, kind: kind)
            }.disabled(trip.events.count >= TripLimits.events)
        }
    }
}

#if DEBUG
#Preview("Add to a journey day") {
    let model = TripJourneyPreview.planner()
    let trip = model.library.trips[0]
    Menu("Add to day", systemImage: "plus") {
        TripDayAddActions(day: trip.days[0], trip: trip, controller: TripController(model: model))
    }.padding()
}
#endif

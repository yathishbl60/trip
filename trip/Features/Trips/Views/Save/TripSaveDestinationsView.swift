import TripLocalization
import SwiftUI
import TripDomain

struct TripSaveDestinationsView: View {
    let place: Place
    let tripID: UUID
    let controller: TripController

    var body: some View {
        Group {
            if let trip = controller.model.library.trip(tripID) { destinations(in: trip) }
            else { ContentUnavailableView(TripText.tripUnavailable.resource, systemImage: "suitcase.rolling") }
        }
        .navigationBarTitleDisplayMode(.inline)
        .collectionNamingAlert(controller, tripID: tripID)
    }

    private func destinations(in trip: TripPlan) -> some View {
        List {
            Section {
                TripPlaceLabel(title: place.name, subtitle: place.address ?? place.category.annotationTitle,
                               symbol: place.category.symbol, color: place.category.color)
            }
            if let notice = controller.model.presentation.notice { Text(notice).foregroundStyle(.secondary) }
            TripSaveSuggestionView(place: place, trip: trip, controller: controller)
            days(in: trip)
            collections(in: trip)
        }
        .navigationTitle(trip.title)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
        .scrollContentBackground(.hidden)
    }

    private func collections(in trip: TripPlan) -> some View {
        Section(TripText.saveForLater.resource) {
            ForEach(trip.collections) { collectionRow($0) }
            Button(TripText.newCollection.resource, systemImage: "plus") { controller.beginCollection(in: tripID) }
                .disabled(trip.collections.count >= TripLimits.collections)
        }
    }

    private func dayRow(_ day: TripDay, in trip: TripPlan) -> some View {
        TripSaveDestinationRow(title: day.title, detail: controller.model.saveDaySummary(day, in: trip),
                               symbol: "calendar", availability: TripStopAvailability(placeID: place.id, stops: day.stops)) {
            controller.reviewPlacement(place, dayID: day.id, tripID: tripID)
        }
    }

    private func days(in trip: TripPlan) -> some View {
        Section(TripText.addToADay.resource) {
            ForEach(trip.days) { dayRow($0, in: trip) }
            Button(TripText.addToANewDay.resource, systemImage: "calendar.badge.plus") {
                controller.saveToNewDay(place, tripID: tripID)
            }.disabled(trip.days.count >= TripLimits.days)
        }
    }

    private func collectionRow(_ collection: TripCollection) -> some View {
        TripSaveDestinationRow(title: collection.title, detail: collection.summary, symbol: "square.stack",
                               availability: TripStopAvailability(placeID: place.id, stops: collection.stops)) {
            controller.save(place, in: collection.id, tripID: tripID)
        }
    }
}

#if DEBUG
#Preview("Choose a day or collection") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        TripSaveDestinationsView(place: PreviewFixtures.hotel, tripID: model.library.trips[0].id,
                                 controller: TripController(model: model))
    }
}
#Preview("Save a place · large text") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        TripSaveDestinationsView(place: PreviewFixtures.longName, tripID: model.library.trips[0].id,
                                 controller: TripController(model: model))
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

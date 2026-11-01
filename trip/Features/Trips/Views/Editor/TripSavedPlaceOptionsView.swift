import TripLocalization
import SwiftUI
import TripDomain

struct TripSavedPlaceOptionsView: View {
    let picker: TripSavedPlacePickerModel
    let trip: TripPlan
    let day: TripDay
    let controller: TripController

    var body: some View {
        let options = picker.options(in: trip)
        if !options.isEmpty {
            Section(TripText.savedInThisTrip.resource) {
                ForEach(options) { option in
                    TripSaveDestinationRow(title: option.stop.place.name, detail: option.source,
                        symbol: option.stop.place.category.symbol,
                        availability: TripStopAvailability(placeID: option.id, stops: day.stops), showsAddIndicator: true) {
                            controller.addSavedPlace(option.id, pickerID: picker.id)
                        }
                        .accessibilityHint(TripText.addToValue(day.title).resource)
                }
            }
        }
    }
}

#if DEBUG
#Preview("Saved places · local, large text") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    let picker = TripSavedPlacePickerModel(tripID: trip.id, dayID: trip.days[1].id)
    List { TripSavedPlaceOptionsView(picker: picker, trip: trip, day: trip.days[1],
                                    controller: TripController(model: model)) }
        .dynamicTypeSize(.accessibility2)
}
#endif

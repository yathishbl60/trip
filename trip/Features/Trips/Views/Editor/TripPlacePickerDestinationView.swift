import TripLocalization
import SwiftUI
import TripDomain

struct TripPlacePickerDestinationView: View {
    let picker: TripSavedPlacePickerModel
    let trip: TripPlan
    let day: TripDay
    let controller: TripController

    var body: some View {
        Section {
            Picker(TripText.addingTo.resource, selection: controller.placePickerDay(picker)) {
                ForEach(trip.days) { day in
                    Text("\(day.title) · \(trip.dateText(for: day))").tag(day.id)
                }
            }
        } header: { Text(trip.title) } footer: {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
                Text(TripText.valuePlanned(day.placeCountText).resource)
                if let origin = picker.searchOrigin { Text(TripText.searchNearValue(origin.name).resource) }
            }
        }
    }
}

#if DEBUG
#Preview("Place destination · local") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    model.beginSavedPlaces(dayID: trip.days[0].id, tripID: trip.id)
    return List {
        TripPlacePickerDestinationView(picker: model.presentation.savedPlacePicker!, trip: trip,
                                      day: trip.days[0], controller: TripController(model: model))
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

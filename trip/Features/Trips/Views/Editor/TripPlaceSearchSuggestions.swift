import TripLocalization
import Foundation
import SwiftUI
import TripDomain

struct TripPlaceSearchSuggestions: View {
    let picker: TripSavedPlacePickerModel
    let controller: TripController

    var body: some View {
        if picker.searchOrigin != nil {
            suggestion(TripText.restaurants.resource, query: TripText.restaurants.text, symbol: "fork.knife")
            suggestion(TripText.coffee.resource, query: TripText.coffeeShops.text, symbol: "cup.and.saucer")
            suggestion(TripText.sights.resource, query: TripText.touristAttractions.text, symbol: "binoculars")
            suggestion(TripText.parks.resource, query: TripText.parks.text, symbol: "leaf")
        } else {
            Label(TripText.searchForAPlaceAddressOrCity.resource, systemImage: "magnifyingglass")
                .foregroundStyle(.secondary)
        }
    }

    private func suggestion(_ title: LocalizedStringResource, query: String, symbol: String) -> some View {
        Button { controller.searchSuggestion(query, picker: picker) } label: {
            Label(title, systemImage: symbol)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: AppTheme.controlTarget, alignment: .leading)
        }
    }
}

#if DEBUG
#Preview("Explore near the day · local") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    let picker = TripSavedPlacePickerModel(tripID: trip.id, dayID: trip.days[0].id)
    picker.prepareSearch(in: trip)
    return List { TripPlaceSearchSuggestions(picker: picker, controller: TripController(model: model)) }
        .dynamicTypeSize(.accessibility2)
}
#endif

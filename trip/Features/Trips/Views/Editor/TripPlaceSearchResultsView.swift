import TripLocalization
import SwiftUI
import TripDomain

struct TripPlaceSearchResultsView: View {
    let picker: TripSavedPlacePickerModel
    let trip: TripPlan
    let day: TripDay
    let controller: TripController

    var body: some View {
        if picker.searchTerm.isEmpty {
            if picker.searchOrigin != nil {
                Section(TripText.exploreNearby.resource) { TripPlaceSearchSuggestions(picker: picker, controller: controller) }
            }
        } else if !picker.isSubmittedSearch {
            TripPlaceSuggestionsView(picker: picker, controller: controller)
        } else if picker.showsMapSearch(in: trip) {
            Section(TripText.appleMaps.resource) {
                results
                status
            }
        }
    }

    private var results: some View {
        ForEach(picker.mapPlaces(in: trip)) { place in
            TripSaveDestinationRow(title: place.name, detail: place.address ?? place.category.annotationTitle,
                symbol: place.category.symbol,
                availability: TripStopAvailability(placeID: place.id, stops: day.stops), showsAddIndicator: true) {
                    controller.addSearchPlace(place, pickerID: picker.id)
                }
                .accessibilityHint(TripText.addToValue(day.title).resource)
        }
    }

    @ViewBuilder private var status: some View {
        if picker.search.isSearching {
            searching
        } else if let error = picker.search.error {
            Text(error).foregroundStyle(.secondary)
            Button(TripText.tryAgain.resource, systemImage: "arrow.clockwise") { controller.retryPlaceSearch(picker) }
        } else if picker.search.resolvedQuery != picker.searchTerm {
            searching
        } else if picker.search.places.isEmpty {
            ContentUnavailableView.search(text: picker.searchTerm)
        }
    }

    private var searching: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            ProgressView().accessibilityHidden(true)
            Text(TripText.findingPlaces.resource).foregroundStyle(.secondary)
        }.accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Search inside a day · local") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    let picker = TripSavedPlacePickerModel(tripID: trip.id, dayID: trip.days[0].id)
    List { TripPlaceSearchResultsView(picker: picker, trip: trip, day: trip.days[0],
                                     controller: TripController(model: model)) }
}
#Preview("Search results · added and available") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    let search = TripPlaceSearchModel(places: [PreviewFixtures.hotel, PreviewFixtures.unrated], query: "Bangkok")
    let picker = TripSavedPlacePickerModel(tripID: trip.id, dayID: trip.days[0].id, search: search)
    picker.query = "Bangkok"
    picker.isSubmittedSearch = true
    return List { TripPlaceSearchResultsView(picker: picker, trip: trip, day: trip.days[0],
                                            controller: TripController(model: model)) }
}
#Preview("Search failed · large text") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    let search = TripPlaceSearchModel(error: "Couldn’t search Apple Maps. Try again.")
    let picker = TripSavedPlacePickerModel(tripID: trip.id, dayID: trip.days[0].id, search: search)
    picker.query = "Museum"
    picker.isSubmittedSearch = true
    return List { TripPlaceSearchResultsView(picker: picker, trip: trip, day: trip.days[0],
                                            controller: TripController(model: model)) }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

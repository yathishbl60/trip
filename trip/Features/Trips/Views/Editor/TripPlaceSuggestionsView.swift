import TripLocalization
import SwiftUI
import TripDomain

struct TripPlaceSuggestionsView: View {
    let picker: TripSavedPlacePickerModel
    let controller: TripController

    var body: some View {
        Section(TripText.appleMapsSuggestions.resource) {
            ForEach(picker.autocomplete.suggestions) { suggestion in
                Button { controller.choosePlaceSuggestion(suggestion.id, picker: picker) } label: {
                    TripPlaceLabel(title: suggestion.title, subtitle: suggestion.subtitle,
                                   symbol: "magnifyingglass", color: .secondary)
                }.buttonStyle(.plain)
            }
            status
        }
    }

    @ViewBuilder private var status: some View {
        if picker.autocomplete.isLoading || picker.search.isSearching {
            HStack {
                ProgressView().accessibilityHidden(true)
                Text(TripText.findingSuggestions.resource)
            }.foregroundStyle(.secondary).accessibilityElement(children: .combine)
        } else if let error = picker.autocomplete.error {
            Text(error).foregroundStyle(.secondary)
            Button(TripText.tryAgain.resource, systemImage: "arrow.clockwise") { controller.retryPlaceSuggestions(picker) }
        } else if picker.autocomplete.suggestions.isEmpty {
            Text(TripText.noSuggestionsTryALongerName.resource).foregroundStyle(.secondary)
            Button(TripText.searchPlaces.resource, systemImage: "magnifyingglass") { controller.retryPlaceSearch(picker) }
        }
    }
}

#if DEBUG
#Preview("Trip prefix suggestions · illustrative local data") {
    let model = PreviewFixtures.tripPlanner()
    let picker = TripPlaceSearchPreview.picker(in: model)
    picker.autocomplete.suggestions = PlaceAutocompletePreview.suggestions
    return List { TripPlaceSuggestionsView(picker: picker, controller: TripController(model: model)) }
}
#Preview("Trip suggestions · failure, large text") {
    let model = PreviewFixtures.tripPlanner()
    let picker = TripPlaceSearchPreview.picker(in: model)
    picker.autocomplete.error = "Couldn’t load suggestions. Try again or submit your search."
    return List { TripPlaceSuggestionsView(picker: picker, controller: TripController(model: model)) }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

import TripLocalization
import SwiftUI
import TripDomain

struct MapAutocompleteSuggestionsView: View {
    let controller: CatalogController
    private var catalog: CatalogModel { controller.model.catalog }

    var body: some View {
        ForEach(catalog.autocomplete.suggestions) { suggestion in
            Button { controller.chooseSuggestion(suggestion.id) } label: {
                TripPlaceLabel(title: suggestion.title, subtitle: suggestion.subtitle,
                               symbol: "magnifyingglass", color: .secondary)
            }.buttonStyle(.plain).disabled(catalog.isFetching)
        }
        status
        if !catalog.isFetching {
            Button(TripText.searchPlaces.resource, systemImage: "magnifyingglass", action: controller.search)
        }
    }

    @ViewBuilder private var status: some View {
        if catalog.autocomplete.isLoading || catalog.isFetching {
            HStack {
                ProgressView().accessibilityHidden(true)
                Text(catalog.isFetching ? TripText.openingPlace.text : TripText.findingSuggestions.text)
            }.font(.subheadline).foregroundStyle(.secondary).accessibilityElement(children: .combine)
        } else if let error = catalog.autocomplete.error ?? (catalog.status.isEmpty ? nil : catalog.status) {
            Text(error).foregroundStyle(.secondary)
            Button(TripText.tryAgain.resource, systemImage: "arrow.clockwise", action: controller.retrySuggestions)
        } else if catalog.autocomplete.suggestions.isEmpty {
            Text(TripText.noSuggestionsTryALongerName.resource).foregroundStyle(.secondary)
        }
    }
}

#if DEBUG
#Preview("Prefix suggestions · illustrative local data") {
    let model = PreviewFixtures.explore()
    model.catalog.autocomplete.suggestions = PlaceAutocompletePreview.suggestions
    return List { MapAutocompleteSuggestionsView(controller: CatalogController(model: model)) }
}
#Preview("Autocomplete · unavailable, large text") {
    let model = PreviewFixtures.explore()
    model.catalog.autocomplete.error = "Couldn’t load suggestions. Try again or submit your search."
    return List { MapAutocompleteSuggestionsView(controller: CatalogController(model: model)) }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Opening a suggestion · local loading state") {
    let model = PreviewFixtures.explore()
    model.catalog.autocomplete.suggestions = PlaceAutocompletePreview.suggestions
    model.catalog.isFetching = true
    return List { MapAutocompleteSuggestionsView(controller: CatalogController(model: model)) }
}
#Preview("Suggestion resolution failed · search recovery") {
    let model = PreviewFixtures.explore()
    model.catalog.status = TripText.couldnTOpenThatSuggestionTryAgain.text
    model.catalog.canRetrySearch = true
    return List { MapAutocompleteSuggestionsView(controller: CatalogController(model: model)) }
        .frame(width: 320).dynamicTypeSize(.accessibility2)
}
#endif

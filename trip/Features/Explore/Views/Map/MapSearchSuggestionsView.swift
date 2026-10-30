import TripLocalization
import SwiftUI
import TripDomain

struct MapSearchSuggestionsView: View {
    let controller: CatalogController
    @Environment(\.dismissSearch) private var dismissSearch

    var body: some View {
        if controller.model.catalog.isTextSearch {
            if controller.model.catalog.isSubmittedSearch {
                results
                status
            } else { MapAutocompleteSuggestionsView(controller: controller) }
        } else {
            Section(TripText.searchThisArea.resource) {
                Label(TripText.restaurants.resource, systemImage: "fork.knife").searchCompletion(TripText.restaurants.text)
                Label(TripText.cafS.resource, systemImage: "cup.and.saucer").searchCompletion(TripText.cafS.text)
                Label(TripText.thingsToDo.resource, systemImage: "sparkles").searchCompletion(TripText.attractions.text)
                Label(TripText.hotels.resource, systemImage: "bed.double").searchCompletion(TripText.hotels.text)
            }
        }
    }

    private var results: some View {
        ForEach(controller.model.catalog.matchingPlaces.prefix(20)) { place in
            HStack(spacing: AppTheme.Spacing.small) {
                Button { choose(place) } label: {
                    TripPlaceLabel(title: place.name, subtitle: place.address ?? place.category.annotationTitle,
                                   symbol: place.category.symbol, color: place.category.color)
                }
                .buttonStyle(.plain)
                .contentShape(.rect).layoutPriority(1)
                if controller.model.canSavePlaces {
                    saveButton(place)
                }
            }
        }
    }

    private func saveButton(_ place: Place) -> some View {
        Button { choose(place, saving: true) } label: {
            Image(systemName: "bookmark")
                .frame(minWidth: AppTheme.controlTarget, minHeight: AppTheme.controlTarget).contentShape(.rect)
        }
        .buttonStyle(.borderless).tint(AppTheme.accent)
        .accessibilityLabel(TripText.saveValueToATrip(place.name).resource).fixedSize()
    }

    @ViewBuilder private var status: some View {
        if controller.model.catalog.isSearching {
            HStack(spacing: AppTheme.Spacing.small) {
                ProgressView().accessibilityHidden(true)
                Text(TripText.searching.resource).foregroundStyle(.secondary)
            }.accessibilityElement(children: .combine)
        } else if !controller.model.catalog.status.isEmpty {
            Text(controller.model.catalog.status).foregroundStyle(.secondary)
            if controller.model.catalog.canRetrySearch {
                Button(TripText.tryAgain.resource, systemImage: "arrow.clockwise", action: controller.search)
            } else {
                Text(TripText.tryAnotherNameOrMoveTheMap.resource).font(.caption).foregroundStyle(.secondary)
            }
        } else if controller.model.catalog.matchingPlaces.isEmpty {
            pendingSearch
        }
    }

    @ViewBuilder private var pendingSearch: some View {
        if controller.model.catalog.pendingSearch != nil {
            Text(TripText.searching.resource).foregroundStyle(.secondary)
        } else {
            Button(TripText.searchThisArea.resource, systemImage: "magnifyingglass", action: controller.search)
        }
    }

    private func choose(_ place: Place, saving: Bool = false) {
        controller.choose(place, saving: saving)
        dismissSearch()
    }
}

#if DEBUG
#Preview("Map search choices · local") {
    let model = PreviewFixtures.searchResults()
    List { MapSearchSuggestionsView(controller: CatalogController(model: model)) }
}
#Preview("Map search · failure") {
    let model = PreviewFixtures.offline()
    model.catalog.query = "Museum"
    model.catalog.isSubmittedSearch = true
    return List { MapSearchSuggestionsView(controller: CatalogController(model: model)) }
        .dynamicTypeSize(.accessibility2)
}
#endif

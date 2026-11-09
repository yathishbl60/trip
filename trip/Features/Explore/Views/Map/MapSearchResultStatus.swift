import SwiftUI
import TripLocalization

struct MapSearchResultStatus: View {
    let controller: CatalogController

    var body: some View {
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
}

#if DEBUG
#Preview("Search status · local failure") {
    List { MapSearchResultStatus(controller: CatalogController(model: PreviewFixtures.offline())) }
}
#endif

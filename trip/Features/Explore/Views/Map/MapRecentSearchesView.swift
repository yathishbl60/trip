import SwiftUI
import TripDomain
import TripLocalization

struct MapRecentSearchesView: View {
    let controller: PlaceHistoryController
    @Environment(\.dismissSearch) private var dismissSearch

    var body: some View {
        if !controller.model.history.history.entries.isEmpty || controller.model.history.error != nil {
            Section {
                ForEach(controller.model.history.history.entries) { entry in
                    Button { choose(entry) } label: { label(entry) }
                }
                status
                Button(TripText.clearRecentHistory.resource, role: .destructive, action: controller.clear)
            } header: { Text(TripText.recentSearchesAndPlaces.resource) }
        }
    }

    @ViewBuilder private var status: some View {
        if let error = controller.model.history.error {
            Text(error).foregroundStyle(.secondary)
            Button(TripText.tryAgain.resource, action: controller.retry)
        }
    }

    @ViewBuilder private func label(_ entry: RecentPlaceEntry) -> some View {
        switch entry {
        case .search(let query): Label(query, systemImage: "clock")
        case .place(let place):
            TripPlaceLabel(title: place.name, subtitle: place.address ?? place.category.title,
                           symbol: place.category.symbol, color: place.category.color)
        }
    }

    private func choose(_ entry: RecentPlaceEntry) {
        controller.choose(entry)
        if case .place = entry { dismissSearch() }
    }
}

#if DEBUG
#Preview("Recent searches and places · local") {
    let model = PreviewFixtures.explore()
    model.history.record(.search("Museums"))
    model.history.record(.place(PreviewFixtures.longName))
    return List { MapRecentSearchesView(controller: PlaceHistoryController(model: model)) }
        .dynamicTypeSize(.accessibility2)
}
#endif

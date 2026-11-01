import TripLocalization
import TripDomain
import SwiftUI

/// List dependencies stay separate from the library's navigation and toolbar.
struct TripLibraryListView: View {
    let controller: TripController

    var body: some View {
        let trips = controller.model.visibleTrips
        List(selection: controller.selection) {
            ForEach(trips) { trip in
                NavigationLink(value: trip.id) { TripRowView(trip: trip) }
                    .contextMenu { TripContextMenu(trip: trip, controller: controller) }
                    .swipeActions { deleteAction(trip) }
            }
        }
        .listStyle(.insetGrouped)
        #if os(iOS)
        .scrollDismissesKeyboard(.interactively)
        #endif
        .overlay {
            if trips.isEmpty {
                ContentUnavailableView.search(text: controller.model.presentation.searchQuery)
            }
        }
    }

    private func deleteAction(_ trip: TripPlan) -> some View {
        // Preserve confirmation before removing a row with a destructive role.
        Button(TripText.delete.resource, systemImage: "trash") { controller.requestDelete(trip.id) }
            .tint(.red)
    }
}

#if DEBUG
#Preview("Library rows · local trips") {
    NavigationStack { TripLibraryListView(controller: TripController(model: PreviewFixtures.tripPlanner())) }
}
#Preview("Library search · no matches, large text") {
    let model = PreviewFixtures.tripPlanner()
    model.presentation.searchQuery = "No matching trip"
    return NavigationStack { TripLibraryListView(controller: TripController(model: model)) }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

import TripLocalization
import TripDomain
import SwiftUI

struct TripCollectionSection: View {
    let trip: TripPlan
    let controller: TripController

    var body: some View {
        content
        .collectionNamingAlert(controller, tripID: trip.id)
        .confirmationDialog(TripText.deleteThisCollectionAndItsSavedPlaces.resource,
                            isPresented: controller.deletingCollection) {
            Button(TripText.deleteCollection.resource, role: .destructive) {
                controller.confirmCollectionDeletion(from: trip.id)
            }
        }
    }

    private var content: some View {
        Section {
            ForEach(trip.collections) { item in
                NavigationLink {
                    TripCollectionView(tripID: trip.id, collectionID: item.id, controller: controller)
                } label: {
                    HStack(spacing: AppTheme.Spacing.medium) {
                        TripSymbolTile(symbol: "square.stack")
                        Text(item.title).font(.headline)
                    }.badge(item.stops.count).padding(.vertical, AppTheme.Spacing.tight)
                }
                .swipeActions { actions(for: item) }
            }
            Button(TripText.newCollection.resource, systemImage: "plus") { controller.beginCollection(in: trip.id) }
                .disabled(trip.collections.count >= TripLimits.collections)
        }
    }

    @ViewBuilder private func actions(for item: TripCollection) -> some View {
        Button(TripText.delete.resource, systemImage: "trash", role: .destructive) {
            controller.requestCollectionDeletion(item.id)
        }
        Button(TripText.rename.resource, systemImage: "pencil") { controller.renameCollection(item, in: trip.id) }
            .tint(AppTheme.accentFill)
    }
}

#if DEBUG
#Preview("Trip collections") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack { List { TripCollectionSection(trip: model.library.trips[0],
                                                    controller: TripController(model: model)) } }
}
#Preview("No collections · dark") {
    let model = PreviewFixtures.emptyTripPlanner()
    let trip = TripPlan(title: "Japan")
    NavigationStack { List { TripCollectionSection(trip: trip, controller: TripController(model: model)) } }
        .preferredColorScheme(.dark)
}
#endif

import TripLocalization
import TripDomain
import SwiftUI

struct TripCollectionSection: View {
    let trip: TripPlan
    let controller: TripCollectionsController

    var body: some View {
        content
        .collectionNamingAlert(controller, tripID: trip.id)
        .confirmationDialog(TripText.deleteThisCollectionAndItsSavedPlaces.resource,
                            isPresented: controller.deletingCollection(in: trip.id),
                            presenting: controller.model.deletion) { session in
            Button(TripText.deleteCollection.resource, role: .destructive) {
                controller.confirmCollectionDeletion(session)
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
            controller.requestCollectionDeletion(item.id, tripID: trip.id)
        }
        Button(TripText.rename.resource, systemImage: "pencil") { controller.renameCollection(item, in: trip.id) }
            .tint(AppTheme.accentFill)
    }
}

#if DEBUG
#Preview("Trip collections") {
    let model = PreviewFixtures.collections()
    NavigationStack { List { TripCollectionSection(trip: model.library.trips[0],
                                                    controller: TripCollectionsController(model: model)) } }
}
#Preview("No collections · dark") {
    let trip = TripPlan(title: "Japan")
    let model = PreviewTripServices.makeCollections([trip])
    NavigationStack { List { TripCollectionSection(trip: trip, controller: TripCollectionsController(model: model)) } }
        .preferredColorScheme(.dark)
}
#endif

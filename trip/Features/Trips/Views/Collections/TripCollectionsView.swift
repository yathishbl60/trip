import TripLocalization
import SwiftUI
import TripDomain

struct TripCollectionsView: View {
    let tripID: UUID
    let controller: TripController

    var body: some View {
        List {
            if let notice = controller.model.presentation.notice { Text(notice).foregroundStyle(.secondary) }
            if let trip = controller.model.library.trip(tripID) {
                TripCollectionSection(trip: trip, controller: controller)
            } else {
                ContentUnavailableView(TripText.tripUnavailable.resource, systemImage: "suitcase.rolling")
            }
        }
        .navigationTitle(TripText.collections.resource)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
#Preview("Saved collections") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        TripCollectionsView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }
}
#endif

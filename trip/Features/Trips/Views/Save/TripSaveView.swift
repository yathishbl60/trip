import TripLocalization
import TripDomain
import SwiftUI

struct TripSaveView: View {
    let place: Place
    let controller: TripController
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            content
            .navigationTitle(controller.model.onlyTrip?.title ?? TripText.saveToTrip.text)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { navigationTools }
        }
        .tripEditSheet(controller, savingPlace: true)
        .tripPlanningSheet(controller, savingPlace: true)
        .presentationSizing(.form)
        .presentationDetents(typeSize.isAccessibilitySize ? [.large] : [.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationContentInteraction(.scrolls)
    }

    @ViewBuilder private var content: some View {
        if let error = controller.model.library.loadError { TripLoadFailureView(error: error, controller: controller) }
        else if !controller.model.library.isReady { ProgressView(TripText.loadingTrips.resource) }
        else if controller.model.library.trips.isEmpty { emptyState }
        else if let trip = controller.model.onlyTrip {
            TripSaveDestinationsView(place: place, tripID: trip.id, controller: controller)
        }
        else { TripSaveChoicesView(place: place, controller: controller, searchText: $searchText) }
    }

    @ToolbarContentBuilder private var navigationTools: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(TripText.cancel.resource, role: .cancel, action: controller.dismissDestination)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button(TripText.newTrip2.resource, systemImage: "plus") { controller.beginCreate(saving: place) }
                .disabled(!controller.model.library.isReady || !controller.model.library.canCreate)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(TripText.createYourFirstTrip.resource, systemImage: "suitcase.rolling")
        } description: {
            Text(TripText.saveValueAsYourFirstStop(place.name).resource)
        } actions: {
            Button(TripText.createATrip.resource) { controller.beginCreate(saving: place) }
                .buttonStyle(.borderedProminent).controlSize(.large)
                .tint(AppTheme.accentFill)
        }
    }
}

#if DEBUG
#Preview("Choose trip and day") {
    TripSaveView(place: PreviewFixtures.hotel,
                 controller: TripController(model: PreviewFixtures.tripPlanner()))
}
#Preview("First saved place · dark") {
    TripSaveView(place: PreviewFixtures.hotel,
                 controller: TripController(model: PreviewFixtures.emptyTripPlanner()))
        .preferredColorScheme(.dark)
}
#endif

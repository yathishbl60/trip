import TripLocalization
import TripDomain
import SwiftUI

struct TripLibraryView: View {
    let controller: TripController

    var body: some View {
        content
            .navigationTitle(TripText.trips.resource)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .toolbar { tools }
            .searchable(text: controller.searchQuery, prompt: Text(TripText.tripsPlacesOrCities.resource))
    }

    @ViewBuilder private var content: some View {
        if let error = controller.model.library.loadError {
            TripLoadFailureView(error: error, controller: controller)
        } else if !controller.model.library.isReady {
            ProgressView(TripText.loadingTrips.resource).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        else if controller.model.library.trips.isEmpty { emptyState }
        else { TripLibraryListView(controller: controller) }
    }

    @ToolbarContentBuilder private var tools: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu(TripText.sortTrips.resource, systemImage: "arrow.up.arrow.down") {
                Picker(TripText.sortTrips.resource, selection: controller.sortOrder) {
                    Text(TripText.newestFirst.resource).tag(TripSortOrder.recent)
                    Text(TripText.departureDate.resource).tag(TripSortOrder.departure)
                }
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button(TripText.newTrip2.resource, systemImage: "plus", action: controller.beginCreate)
                .buttonStyle(TripButtonStyles.prominent).keyboardShortcut("n")
                .tint(AppTheme.accentFill)
                .disabled(!controller.model.library.isReady || !controller.model.library.canCreate)
                .disabled(controller.model.hasEditingSession)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(TripText.planYourFirstTrip.resource, systemImage: "suitcase.rolling")
                .symbolColorRenderingMode(.gradient)
        } description: {
            Text(TripText.savePlacesFromTheMapAndPlanEachDay.resource)
        } actions: {
            Button(TripText.createATrip.resource, action: controller.beginCreate).buttonStyle(TripButtonStyles.prominent)
                .tint(AppTheme.accentFill)
        }
    }

}

#if DEBUG
#Preview("Trip library") {
    TripLibraryView(controller: TripController(model: PreviewFixtures.tripPlanner()))
}
#Preview("First trip · dark") {
    TripLibraryView(controller: TripController(model: PreviewFixtures.emptyTripPlanner()))
        .preferredColorScheme(.dark)
}
#endif

import TripLocalization
import TripDomain
import SwiftUI

struct TripSavedPlacesView: View {
    let picker: TripSavedPlacePickerModel
    let controller: TripController
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack { searchContent }
            .task(id: picker.searchTaskID) { await controller.searchPlaces(picker) }
            .onChange(of: controller.model.library.trip(picker.tripID)?.days, initial: true) {
                controller.reconcilePlacePicker(picker)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { TripPlaceAdditionFeedback(picker: picker, controller: controller) }
            .onDisappear { picker.cancelSearch() }
            .onChange(of: scenePhase) { _, phase in controller.placeSearchPhaseChanged(phase, picker: picker) }
    }

    private var searchContent: some View {
        content
            .navigationTitle(TripText.addPlaces.resource)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: controller.savedPlacesSearch(picker),
                        placement: .navigationBarDrawer(displayMode: .always), prompt: Text(TripText.placeAddressOrCity.resource))
            .onSubmit(of: .search) { controller.retryPlaceSearch(picker) }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(TripText.done.resource) { controller.closeSavedPlaces(picker.id) }
                }
            }
    }

    @ViewBuilder private var content: some View {
        if let trip = controller.model.library.trip(picker.tripID),
           let day = trip.days.first(where: { $0.id == picker.dayID }) {
            places(in: trip, day: day)
        } else {
            ContentUnavailableView(TripText.dayUnavailable.resource, systemImage: "calendar.badge.exclamationmark")
        }
    }

    private func places(in trip: TripPlan, day: TripDay) -> some View {
        List {
            TripPlacePickerDestinationView(picker: picker, trip: trip, day: day, controller: controller)
            if picker.searchTerm.isEmpty {
                TripPlaceSearchResultsView(picker: picker, trip: trip, day: day, controller: controller)
            }
            TripSavedPlaceOptionsView(picker: picker, trip: trip, day: day, controller: controller)
            if !picker.searchTerm.isEmpty {
                TripPlaceSearchResultsView(picker: picker, trip: trip, day: day, controller: controller)
            }
            if let notice = picker.notice { Text(notice).foregroundStyle(.secondary) }
        }
        #if os(iOS)
        .scrollDismissesKeyboard(.interactively)
        #endif
    }

}

#if DEBUG
#Preview("Add saved places") {
    let model = PreviewFixtures.tripPlanner()
    let picker = TripPlaceSearchPreview.picker(in: model, dayIndex: 1)
    return TripSavedPlacesView(picker: picker, controller: TripController(model: model))
}
#Preview("Saved places · large text") {
    let model = PreviewFixtures.tripPlanner()
    let picker = TripPlaceSearchPreview.picker(in: model)
    return TripSavedPlacesView(picker: picker, controller: TripController(model: model))
        .dynamicTypeSize(.accessibility2)
}
#Preview("Search results in day · local, narrow") {
    let model = PreviewFixtures.tripPlanner()
    let picker = TripPlaceSearchPreview.picker(in: model, query: "Bangkok",
                                              places: [PreviewFixtures.hotel, PreviewFixtures.longName])
    return TripSavedPlacesView(picker: picker, controller: TripController(model: model))
        .frame(width: 320).preferredColorScheme(.dark)
}
#Preview("Search retry · existing results remain available") {
    let model = PreviewFixtures.tripPlanner()
    let picker = TripPlaceSearchPreview.picker(in: model, query: "Bangkok", places: [PreviewFixtures.hotel],
                                              error: "Couldn’t refresh places. Try again.")
    return TripSavedPlacesView(picker: picker, controller: TripController(model: model))
        .frame(width: 320).dynamicTypeSize(.accessibility2)
}
#endif

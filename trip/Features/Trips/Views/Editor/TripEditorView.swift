import TripLocalization
import TripDomain
import AppIntents
import SwiftUI

struct TripEditorView: View {
    let tripID: UUID
    let controller: TripController

    var body: some View {
        content
            .navigationDestination(item: controller.detailRoute(for: tripID), destination: destination)
            .confirmationDialog(TripText.deleteThisDayItsPlacesAndEventsOnlyOn.resource,
                                isPresented: controller.deletingDay, titleVisibility: .visible) { deleteDay }
            .sheet(isPresented: controller.assistantPresentation) {
                TripAssistantView(tripID: tripID, controller: controller)
            }
            .tripSavedPlaceSheet(controller)
            .tripStopOrderSheet(controller)
            .tripPlanningSheet(controller)
            .tripScheduleSheets(controller)
            .tripEventSheet(controller)
            .tripNativeServiceSheets(controller)
    }

    private var deleteDay: some View {
        Button(TripText.deleteDay.resource, role: .destructive) { controller.confirmDayDelete(from: tripID) }
    }

    @ViewBuilder private func destination(_ route: TripDetailRoute) -> some View {
        switch route.destination {
        case .map:
            TripMapView(tripID: route.tripID, initialDayID: route.dayID, controller: controller)
                .id(route.dayID).modifier(TripHingeObservation())
        case .checklist:
            TripChecklistView(tripID: route.tripID, controller: TripChecklistController(model: controller.model.checklist))
                .tripWayfinding(.checklist, tripID: route.tripID, controller: controller)
        case .collections:
            TripCollectionsView(tripID: route.tripID, controller: controller.collections)
                .tripWayfinding(.collections, tripID: route.tripID, controller: controller)
        case .collection(let id):
            TripCollectionView(tripID: route.tripID, collectionID: id, controller: controller.collections)
        case .lookup: TripLookupView(tripID: route.tripID, controller: controller)
        case .today:
            TripTodayView(tripID: route.tripID, controller: controller).modifier(TripHingeObservation())
        }
    }

    @ViewBuilder private var content: some View {
        if let trip = controller.model.library.trip(tripID) { editor(trip) }
        else { ContentUnavailableView(TripText.tripUnavailable.resource, systemImage: "suitcase.rolling") }
    }

    private func editor(_ trip: TripPlan) -> some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            TripItineraryView(trip: trip, controller: controller, now: context.date)
        }
        .navigationTitle(trip.title)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        .navigationBarTitleDisplayMode(.large)
        #else
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar { TripEditorToolbar(trip: trip, controller: controller) }
        .tripWayfinding(.itinerary, tripID: tripID, controller: controller)
    }

}

#if DEBUG
#Preview("Day-by-day plan · local data") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        TripEditorView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }
}
#Preview("Large text · dark, local data") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        TripEditorView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Timed itinerary · local data") {
    let model = TripSchedulePreview.planner(overloaded: true)
    NavigationStack {
        TripEditorView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }
}
#Preview("Checklist host navigation · local data") {
    let model = PreviewFixtures.tripPlanner()
    let tripID = model.library.trips[0].id
    NavigationStack {
        TripChecklistView(tripID: tripID, controller: TripChecklistController(model: model.checklist))
            .tripWayfinding(.checklist, tripID: tripID, controller: TripController(model: model))
    }
}
#endif

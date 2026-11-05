import TripLocalization
import SwiftUI
import TripDomain

struct TripLookupView: View {
    let tripID: UUID
    let controller: TripController
    private var lookup: TripLookupController { TripLookupController(model: controller.model.lookup) }
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        content
            .navigationTitle(TripText.askMyTrip.resource)
            .tripWayfinding(.details, tripID: tripID, controller: controller)
            .searchable(text: lookup.searchText, prompt: Text(TripText.namePlaceOrBooking.resource))
            #if os(iOS)
            .scrollDismissesKeyboard(.interactively)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .onDisappear(perform: lookup.cancel)
            .onChange(of: controller.lookupSnapshot(tripID)) { _, plan in lookup.model.refresh(plan) }
            .onChange(of: scenePhase) { _, phase in lookup.sceneChanged(phase) }
    }

    private var content: some View {
        List {
            TripAIProcessingSection(selection: lookup.processing, explanation: lookup.model.processing.lookupExplanation,
                                    availableModes: TripAIConfiguration.availableModes)
            TripLookupControls(controller: lookup)
            if let error = lookup.model.error {
                Section { Label(error, systemImage: "exclamationmark.circle").foregroundStyle(.secondary) }
            }
            TripLookupResultsSection(tripID: tripID, controller: controller)
        }
    }

}

#if DEBUG
#Preview("Ask my trip · saved journey") {
    let model = TripJourneyPreview.planner()
    model.lookup.prepare(model.library.trips[0])
    return NavigationStack {
        TripLookupView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }
}
#Preview("Ask my trip · unavailable and large text") {
    let model = PreviewFixtures.tripPlanner()
    model.lookup.prepare(model.library.trips[0])
    model.lookup.unavailableReason = "Use quick filters to find details on this device."
    return NavigationStack {
        TripLookupView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Ask my trip · retry keeps itinerary") {
    let model = TripJourneyPreview.planner()
    model.lookup.prepare(model.library.trips[0])
    model.lookup.error = "Couldn’t understand that question. Try rephrasing it or use a quick filter."
    return NavigationStack {
        TripLookupView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }
}
#Preview("Search details · no Intelligence, combined filters") {
    let model = TripJourneyPreview.planner()
    model.lookup.prepare(model.library.trips[0])
    model.lookup.choose(.stays)
    model.lookup.chooseDay(2)
    model.lookup.setSearchText("hotel")
    model.lookup.unavailableReason = "Use search or filters to find saved details."
    return NavigationStack {
        TripLookupView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }.dynamicTypeSize(.accessibility2)
}
#endif

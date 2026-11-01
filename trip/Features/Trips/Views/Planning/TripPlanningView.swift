import SwiftUI
import TripDomain
import TripLocalization

struct TripPlanningView: View {
    let draft: TripPlanningDraft
    let controller: TripController
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        navigation
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .tripDraftDismissal(draft, controller: controller) { controller.closePlanning(draft) }
        .task(id: draft.routeRequest) {
            if scenePhase == .active { await controller.refreshPlanning(draft) }
        }
        .onDisappear { controller.suspendPlanning(draft) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { controller.retryPlanning(draft) }
            else { controller.suspendPlanning(draft) }
        }
    }

    private var navigation: some View {
        NavigationStack {
            content
                .navigationTitle(draft.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { actions }
                #if os(iOS)
                .scrollEdgeEffectStyle(.soft, for: .top)
                #endif
        }
    }

    private var content: some View {
        List {
            Section {
                TripPlanningMapView(draft: draft).frame(height: 240).listRowInsets(EdgeInsets())
            } header: { Text("\(draft.trip.title) · \(draft.day.title)") }
            TripPlanningRouteSummary(draft: draft, controller: controller)
            TripPlanningScheduleSection(draft: draft)
            TripPlanningVisitsSection(draft: draft, controller: controller)
            TripPlanningBookingsSection(draft: draft)
            if let issue = controller.model.planningIssue(draft) ?? draft.notice {
                Section { Label(issue, systemImage: "exclamationmark.triangle") }
            }
        }
    }

    @ToolbarContentBuilder private var actions: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(TripText.cancel.resource) {
                controller.requestDiscard(draft) { controller.closePlanning(draft) }
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(draft.confirmationTitle) { controller.applyPlanning(draft) }
                .disabled(!draft.hasChanges || controller.model.planningIssue(draft) != nil)
        }
    }
}

extension View {
    func tripPlanningSheet(_ controller: TripController, savingPlace: Bool = false) -> some View {
        sheet(item: controller.planning(savingPlace: savingPlace)) { draft in TripPlanningView(draft: draft, controller: controller) }
    }
}

#if DEBUG
#Preview("Day rehearsal · local routing fixture") {
    let (model, draft) = TripPlanningPreview.fixture()
    TripPlanningView(draft: draft, controller: TripController(model: model))
}
#Preview("Save placement · large text") {
    let (model, draft) = TripPlanningPreview.fixture(inserting: true)
    TripPlanningView(draft: draft, controller: TripController(model: model))
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Reorder a day · compact sheet") {
    let (model, draft) = TripPlanningPreview.fixture()
    TripPlanningView(draft: draft, controller: TripController(model: model))
        .frame(width: 320, height: 640)
}
#Preview("Discard day-order changes") {
    let (model, draft) = TripPlanningPreview.fixture()
    draft.isDiscarding = true
    return TripPlanningView(draft: draft, controller: TripController(model: model))
}
#endif

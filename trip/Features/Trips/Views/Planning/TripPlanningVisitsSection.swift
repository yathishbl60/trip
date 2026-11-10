import SwiftUI
import TripLocalization

struct TripPlanningVisitsSection: View {
    let draft: TripPlanningDraft
    let controller: TripController

    var body: some View {
        Section {
            if draft.canChoosePlacement { placementPicker }
            ForEach(draft.visits) { visit in
                TripPlanningVisitRow(visit: visit).moveDisabled(visit.isFixed || draft.isInsertion)
            }
            .onMove { controller.movePlanning($0, to: $1, draft: draft) }
            if !draft.isInsertion {
                Button(TripText.planningRestore.resource, systemImage: "arrow.uturn.backward") {
                    controller.restorePlanning(draft)
                }.disabled(!draft.hasChanges)
            }
        } header: { Text(TripText.stopOrder.resource) }
        .environment(\.editMode, .constant(.active))
    }

    private var placementPicker: some View {
        Picker(TripText.planningInsertBefore.resource, selection: controller.planningPosition(draft)) {
            ForEach(draft.placementOptions) { option in Text(option.title).tag(option.id) }
        }
    }
}

#if DEBUG
#Preview("Reorder visits · fixed arrival") {
    let (model, draft) = TripPlanningPreview.fixture()
    List { TripPlanningVisitsSection(draft: draft, controller: TripController(model: model)) }
}
#Preview("Reorder visits · large text") {
    let (model, draft) = TripPlanningPreview.fixture(inserting: true)
    List { TripPlanningVisitsSection(draft: draft, controller: TripController(model: model)) }
        .dynamicTypeSize(.accessibility2)
}
#Preview("First stop · focused confirmation") {
    let (model, draft) = TripPlanningPreview.firstStop()
    TripPlanningView(draft: draft, controller: TripController(model: model))
}
#endif

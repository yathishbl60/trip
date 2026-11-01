import TripLocalization
import SwiftUI
import TripDomain

struct TripPackingView: View {
    let tripID: UUID
    let controller: TripController
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TripPackingForm(tripID: tripID, controller: controller)
            .navigationTitle(TripText.packingSuggestions.resource)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { TripPackingToolbar(tripID: tripID, controller: controller) }
            .onDisappear(perform: controller.cancelPacking)
            .onChange(of: controller.model.library.trip(tripID).map(TripPackingContext.init)) { _, _ in controller.refreshPacking(tripID) }
            .onChange(of: controller.model.library.trip(tripID)?.checklist.map(\.title)) { _, _ in controller.refreshPacking(tripID) }
            .onChange(of: scenePhase) { _, phase in controller.packingSceneChanged(phase) }
    }
}

#if DEBUG
#Preview("Packing · local review") {
    let model = TripPackingPreview.planner()
    NavigationStack { TripPackingView(tripID: model.library.trips[0].id, controller: TripController(model: model)) }
}
#Preview("Packing · unavailable · large text") {
    let model = TripPackingPreview.planner(unavailable: true)
    NavigationStack { TripPackingView(tripID: model.library.trips[0].id, controller: TripController(model: model)) }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Packing · loading preserves review") {
    let model = TripPackingPreview.planner()
    model.packing.isGenerating = true
    return NavigationStack { TripPackingView(tripID: model.library.trips[0].id, controller: TripController(model: model)) }
}
#Preview("Packing · before generation") {
    let model = TripPackingPreview.planner()
    model.packing.suggestions = []
    model.packing.selected = []
    return NavigationStack { TripPackingView(tripID: model.library.trips[0].id, controller: TripController(model: model)) }
}
#endif

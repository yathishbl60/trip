import SwiftUI
import TripDomain

/// Library edits reconcile selection without rebuilding the split-view parent.
struct TripSelectionSynchronization: ViewModifier {
    let controller: TripController

    func body(content: Content) -> some View {
        content
            .onChange(of: controller.model.library.trips.map(\.id), initial: true) {
                controller.reconcileSelection()
            }
            .onChange(of: controller.model.library.isReady) {
                controller.reconcileSelection()
            }
    }
}

#if DEBUG
#Preview("Selection synchronization · selected trip") {
    let model = PreviewFixtures.tripPlanner()
    model.selectTrip(model.library.trips.first?.id)
    return TripManagerView(controller: TripController(model: model))
        .frame(width: 1000, height: 700)
}
#Preview("Selection synchronization · empty library") {
    TripManagerView(controller: TripController(model: PreviewFixtures.emptyTripPlanner()))
}
#endif

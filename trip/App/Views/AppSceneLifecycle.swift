import SwiftUI
import Foundation

struct AppSceneLifecycle: ViewModifier {
    let controller: AppController
    let initialTripID: UUID?
    @Environment(\.scenePhase) private var phase
    @SceneStorage("trip.tab") private var tab = "trips"
    @SceneStorage("trip.selection") private var tripID = ""

    func body(content: Content) -> some View {
        content
            .task(id: phase) { await controller.start(phase, tab: tab, tripID: tripID, initialTripID: initialTripID) }
            .onChange(of: controller.model.navigation.tab) { _, value in tab = value.rawValue }
            .onChange(of: controller.model.trips.selectedTripID) { _, id in tripID = id?.uuidString ?? "" }
    }
}

#if DEBUG
#Preview("Scene lifecycle · local trips") {
    let controller = AppController(model: PreviewFixtures.app())
    return Text("Trip window").modifier(AppSceneLifecycle(controller: controller, initialTripID: nil))
}
#endif

import TripLocalization
import SwiftUI
import TripDomain

struct TripManagerView: View {
    let controller: TripController

    var body: some View {
        workspace
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .tripEditSheet(controller)
            .confirmationDialog(TripText.deleteThisTripAndItsSavedPlaces.resource, isPresented: controller.deletingTrip) {
                Button(TripText.deleteTrip.resource, role: .destructive, action: controller.confirmDelete)
            }
            .modifier(TripSelectionSynchronization(controller: controller))
    }

    private var workspace: some View {
        NavigationSplitView(preferredCompactColumn: controller.compactColumn) {
            TripLibraryView(controller: controller)
                .navigationSplitViewColumnWidth(min: 280, ideal: 340, max: 440)
        } detail: {
            NavigationStack {
                if let id = controller.model.selectedTripID {
                    TripEditorView(tripID: id, controller: controller).id(id)
                } else {
                    ContentUnavailableView(TripText.chooseATrip.resource, systemImage: "suitcase.rolling")
                }
            }
        }
    }
}

#if DEBUG
#Preview("Trip library · compact") {
    TripManagerView(controller: TripController(model: PreviewFixtures.tripPlanner()))
}
#Preview("Trip library · wide, selected") {
    let model = PreviewFixtures.tripPlanner()
    model.selectTrip(model.library.trips[0].id)
    return TripManagerView(controller: TripController(model: model)).frame(width: 1000, height: 700)
}
#Preview("Trip library · narrow, large text") {
    TripManagerView(controller: TripController(model: PreviewFixtures.tripPlanner()))
        .frame(width: 360, height: 640).dynamicTypeSize(.accessibility2)
}
#Preview("First trip · dark") {
    TripManagerView(controller: TripController(model: PreviewFixtures.emptyTripPlanner()))
        .preferredColorScheme(.dark)
}
#endif

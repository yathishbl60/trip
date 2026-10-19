#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI
import TripDomain

struct DirectionsStopsView: View {
    let controller: DirectionsController
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            stops
                .navigationTitle(TripText.routeStops.resource)
                #if os(iOS)
                .scrollEdgeEffectStyle(.soft, for: .top)
                #endif
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { EditButton() }
                    ToolbarItem(placement: .confirmationAction) { Button(TripText.done.resource) { dismiss() } }
                }
                .navigationDestination(isPresented: controller.choosingPlace) {
                    if let session = controller.model.presentation.placePicker {
                        DirectionsStopPickerView(controller: controller, session: session)
                    }
                }
        }
    }

    private var stops: some View {
        List {
            Section {
                Button(action: controller.changeOrigin) {
                    Label(controller.model.startingPoint.title, systemImage: controller.model.startingPoint.symbol)
                }
                .tint(.primary)
            }
            stopSection(controller.model.stops)
            if let destination = controller.directions.destination {
                Section(TripText.destination.resource) { Label(destination.name, systemImage: destination.category.symbol) }
            }
        }
    }

    private func stopSection(_ snapshot: [Place]) -> some View {
        Section(TripText.stops.resource) {
            ForEach(snapshot) { place in
                Button(place.name) { controller.changePlace(place) }.tint(.primary)
            }
            .onDelete { controller.removeStops($0, in: snapshot) }
            .onMove { controller.moveStops($0, to: $1, in: snapshot) }
            Button(TripText.addStop.resource, systemImage: "plus.circle.fill", action: controller.beginAddingStop)
                .disabled(!controller.model.canAddStop)
        }
    }

}

#if DEBUG
#Preview("Reorder route stops · local places") {
    let model = DirectionsPreviewFixtures.ready()
    model.stops = Array(model.environment.loadedPlaces().prefix(2))
    return DirectionsStopsView(controller: DirectionsController(model: model))
}
#Preview("Empty stops") {
    DirectionsStopsView(controller: DirectionsController(model: DirectionsPreviewFixtures.ready()))
}
#endif
#endif

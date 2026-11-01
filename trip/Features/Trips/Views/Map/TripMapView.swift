import TripLocalization
import SwiftUI
import TripDomain

struct TripMapView: View {
    let controller: TripController
    @State private var model: TripMapModel

    init(tripID: UUID, initialDayID: UUID? = nil, controller: TripController) {
        self.controller = controller
        _model = State(initialValue: TripMapModel(tripID: tripID, initialDayID: initialDayID,
                                                library: controller.model.library))
    }

    var body: some View {
        content
            .navigationTitle(model.trip?.title ?? TripText.tripMap.text)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            #endif
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { TripMapToolbar(controller: TripMapController(model: model)) }
            .onChange(of: model.stops, initial: true) { TripMapController(model: model).reconcile() }
            .onChange(of: model.day?.id) { TripMapController(model: model).reconcile() }
    }

    @ViewBuilder private var content: some View {
        if model.trip != nil {
            if model.stops.isEmpty { TripMapEmptyDayView() }
            else if model.mappedStops.isEmpty { stops }
            else {
                TripMapLayout {
                    TripMapCanvas(controller: TripMapController(model: model))
                } detail: { stops }
            }
        } else { ContentUnavailableView(TripText.tripUnavailable.resource, systemImage: "suitcase.rolling") }
    }

    private var stops: some View {
        TripMapStopsView(map: TripMapController(model: model), trips: controller)
    }
}

#if DEBUG
#Preview("Trip map · local stops, live map tiles") {
    let model = TripMapPreview.planner()
    NavigationStack {
        TripMapView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }
}
#Preview("Trip map · wide, live map tiles") {
    let model = TripMapPreview.planner()
    NavigationStack {
        TripMapView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }.frame(width: 1000, height: 700)
}
#Preview("Trip map · compact, dark, live map tiles") {
    let model = TripMapPreview.planner()
    NavigationStack {
        TripMapView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }.frame(width: 320, height: 600).preferredColorScheme(.dark)
}
#Preview("Trip map · large text, live map tiles") {
    let model = TripMapPreview.planner()
    NavigationStack {
        TripMapView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }.dynamicTypeSize(.accessibility2)
}
#Preview("Trip map · empty day, no repeated states, local") {
    let model = TripMapPreview.planner()
    let trip = model.library.trips[0]
    NavigationStack {
        TripMapView(tripID: trip.id, initialDayID: trip.days[1].id, controller: TripController(model: model))
    }
}
#Preview("Missing locations · stop list only, local") {
    let model = TripMapPreview.planner(missingLocations: true)
    NavigationStack {
        TripMapView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }
}
#endif

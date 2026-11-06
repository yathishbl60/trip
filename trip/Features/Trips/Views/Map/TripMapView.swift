import TripLocalization
import SwiftUI
import TripDomain
import CoreGraphics

struct TripMapView: View {
    let controller: TripController
    private let reservedDivision: CGRect?
    @State private var model: TripMapModel

    init(tripID: UUID, initialDayID: UUID? = nil, controller: TripController, reservedDivision: CGRect? = nil) {
        self.controller = controller
        self.reservedDivision = reservedDivision
        _model = State(initialValue: TripMapModel(tripID: tripID, initialDayID: initialDayID,
                                                library: controller.model.library))
    }

    var body: some View {
        content
            .navigationTitle(TripText.tripMap.resource)
            .tripWayfinding(.map, tripID: model.tripID, controller: controller)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            #endif
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: model.stops, initial: true) { TripMapController(model: model).reconcile() }
            .onChange(of: model.day?.id) { TripMapController(model: model).reconcile() }
    }

    @ViewBuilder private var content: some View {
        if model.mappedStops.isEmpty {
            unmappedContent.toolbar { TripMapToolbar(controller: map) }
        } else {
            TripMapLayout(reservedDivision: reservedDivision) {
                TripMapCanvas(controller: map)
            } detail: { dayPickerInList in
                TripMapStopsView(map: map, trips: controller, dayPickerInList: dayPickerInList)
                    .toolbar { TripMapToolbar(controller: map, showsDayPicker: !dayPickerInList) }
            }
        }
    }

    @ViewBuilder private var unmappedContent: some View {
        if model.trip == nil { ContentUnavailableView(TripText.tripUnavailable.resource, systemImage: "suitcase.rolling") }
        else if model.stops.isEmpty { TripMapEmptyDayView() }
        else { TripMapStopsView(map: map, trips: controller) }
    }

    private var map: TripMapController { TripMapController(model: model) }
}

#if DEBUG
#Preview("Trip map · Duo tabletop day selection, live map tiles") {
    let model = TripMapPreview.planner()
    NavigationStack {
        TripMapView(tripID: model.library.trips[0].id, controller: TripController(model: model),
                    reservedDivision: CGRect(x: 0, y: 300, width: 600, height: 20))
    }.frame(width: 600, height: 650).environment(\.tripHingePartiallyOpen, true)
}
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

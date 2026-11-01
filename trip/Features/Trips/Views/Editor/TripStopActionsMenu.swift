import TripLocalization
import TripDomain
import SwiftUI

struct TripStopActionsMenu: View {
    let stop: TripStop
    let dayID: UUID
    let tripID: UUID
    let controller: TripController

    var body: some View {
        Menu {
            Button(TripText.showOnMap.resource, systemImage: "map") { controller.showOnMap(stop.place) }
            timingAction
            destinations
            if let url = stop.place.mapsURL {
                ShareLink(item: url, preview: SharePreview(stop.place.name))
            }
        } label: {
            Image(systemName: "ellipsis").frame(minWidth: AppTheme.controlTarget, minHeight: AppTheme.controlTarget)
                .contentShape(.rect)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(TripText.actionsForValue(stop.place.name).resource)
    }

    @ViewBuilder private var timingAction: some View {
        if let day = controller.model.library.trip(tripID)?.days.first(where: { $0.id == dayID }),
           day.schedule != nil {
            Button(TripText.editVisitTime.resource, systemImage: "clock") {
                controller.beginStopTiming(stopID: stop.id, dayID: dayID, tripID: tripID)
            }
        }
    }

    @ViewBuilder private var destinations: some View {
        if let trip = controller.model.library.trip(tripID), trip.days.count > 1 {
            Menu(TripText.moveToDay.resource, systemImage: "calendar") {
                ForEach(trip.days) { day in
                    if day.id != dayID {
                        Button(destinationTitle(day)) {
                            controller.moveStop(stop.id, from: dayID, to: day.id, tripID: tripID)
                        }
                        .disabled(TripStopAvailability(placeID: stop.place.id, stops: day.stops) != .available)
                    }
                }
            }.disabled(controller.model.tracking.isBusy)
        }
    }

    private func destinationTitle(_ day: TripDay) -> String {
        switch TripStopAvailability(placeID: stop.place.id, stops: day.stops) {
        case .available: day.title
        case .alreadySaved: TripText.valueAlreadySaved(day.title).text
        case .full: TripText.valueFull(day.title).text
        }
    }
}

#if DEBUG
#Preview("Move a stop", traits: .sizeThatFitsLayout) {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    TripStopActionsMenu(stop: trip.days[0].stops[0], dayID: trip.days[0].id, tripID: trip.id,
                        controller: TripController(model: model)).padding()
}
#endif

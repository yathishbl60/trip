import TripLocalization
import TripDomain
import SwiftUI

struct TripDayActionsMenu: View {
    let day: TripDay
    let trip: TripPlan
    let controller: TripController

    var body: some View {
        Menu { items } label: {
            Image(systemName: "ellipsis")
                .frame(minWidth: AppTheme.controlTarget, minHeight: AppTheme.controlTarget)
                .contentShape(.rect)
        }
        .controlSize(.large)
        .accessibilityLabel(TripText.optionsForValue(day.title).resource)
    }

    private var items: some View {
        Group {
            Button(day.schedule == nil ? TripText.planTimes.text : TripText.editSchedule.text, systemImage: "clock") {
                controller.beginDaySchedule(dayID: day.id, tripID: trip.id)
            }
            planningActions
            suggestions
            trackingAction
            reorderActions
            if trip.days.count > 1 {
                Divider()
                Button(TripText.deleteDay.resource, systemImage: "trash", role: .destructive) {
                    controller.requestDayDelete(day.id)
                }
            }
        }
    }

    @ViewBuilder private var suggestions: some View {
        if !day.stops.isEmpty {
            NavigationLink {
                TripMapView(tripID: trip.id, initialDayID: day.id, controller: controller)
            } label: { Label(TripText.showDayOnMap.resource, systemImage: "map") }
            TripDayReviewActions(day: day, trip: trip, controller: controller)
            TripDayWeatherAction(day: day, trip: trip, controller: controller)
        }
        if !trip.journeyItems(on: day).isEmpty {
            ShareLink(item: day.shareText(in: trip), preview: SharePreview("\(trip.title) · \(day.title)")) {
                Label(TripText.shareDay.resource, systemImage: "square.and.arrow.up")
            }
        }
    }

    @ViewBuilder private var planningActions: some View {
        Menu(TripText.addToDay.resource, systemImage: "plus") {
            TripDayAddActions(day: day, trip: trip, controller: controller)
        }
        if !day.stops.isEmpty {
            Button(TripText.directions.resource, systemImage: "arrow.triangle.turn.up.right.diamond") {
                controller.showDirections(dayID: day.id, tripID: trip.id)
            }.disabled(controller.model.dayDirectionsIssue(day, tripID: trip.id) != nil)
            if let issue = controller.model.dayDirectionsIssue(day, tripID: trip.id) {
                Label(issue, systemImage: "info.circle")
            }
        }
    }

    @ViewBuilder private var trackingAction: some View {
        if controller.model.tracking.isAvailable, !day.stops.isEmpty {
            Button(TripText.trackDay.resource, systemImage: "figure.walk") {
                controller.startTracking(dayID: day.id, tripID: trip.id)
            }.disabled(controller.model.tracking.isBusy)
        }
    }

    @ViewBuilder private var reorderActions: some View {
        if trip.days.count > 1 {
            Divider()
            Button(TripText.moveDayEarlier.resource, systemImage: "arrow.up") {
                controller.moveDay(day.id, by: -1, tripID: trip.id)
            }.disabled(day.id == trip.days.first?.id || controller.model.tracking.isBusy)
            Button(TripText.moveDayLater.resource, systemImage: "arrow.down") {
                controller.moveDay(day.id, by: 1, tripID: trip.id)
            }.disabled(day.id == trip.days.last?.id || controller.model.tracking.isBusy)
        }
    }
}

#if DEBUG
#Preview("Day planning actions", traits: .sizeThatFitsLayout) {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    TripDayActionsMenu(day: trip.days[0], trip: trip, controller: TripController(model: model)).padding()
}
#endif

import SwiftUI
import TripDomain

struct TripJourneyRows: View {
    let trip: TripPlan
    let day: TripDay
    let controller: TripController
    let model: TripJourneyDayModel

    init(trip: TripPlan, day: TripDay, controller: TripController) {
        self.trip = trip
        self.day = day
        self.controller = controller
        model = TripJourneyDayModel(trip: trip, day: day)
    }

    var body: some View {
        ForEach(model.items) { item in
            row(item).listRowSeparator(.hidden)
        }
        .onMove { controller.moveJourneyItems($0, to: $1, day: day, trip: trip) }
        .onDelete { controller.removeJourneyVisits($0, day: day, trip: trip) }
    }

    @ViewBuilder private func row(_ item: TripJourneyItem) -> some View {
        switch item {
        case .visit(let stop):
            TripStopPlanningRow(stop: stop, dayID: day.id, tripID: trip.id, controller: controller,
                                number: model.number(for: stop), timing: model.timeline?[stop.id],
                                continuesSequence: model.continues(after: item))
        case .event(let event):
            TripEventRow(model: TripEventPresentation(event: event, day: day, trip: trip),
                         controller: controller, continuesSequence: model.continues(after: item))
                .deleteDisabled(true)
        }
    }
}

#if DEBUG
#Preview("Complete journey") {
    let model = TripJourneyPreview.planner()
    let trip = model.library.trips[0]
    List { TripJourneyRows(trip: trip, day: trip.days[0], controller: TripController(model: model)) }
}
#Preview("Complete journey · edit order") {
    let model = TripJourneyPreview.planner()
    let trip = model.library.trips[0]
    List { TripJourneyRows(trip: trip, day: trip.days[0], controller: TripController(model: model)) }
        .environment(\.editMode, .constant(.active))
}
#endif

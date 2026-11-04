import Foundation
import SwiftUI
import TripDomain
import TripLocalization

struct TripJourneyRows: View {
    let trip: TripPlan
    let day: TripDay
    let controller: TripController
    let model: TripJourneyDayModel
    @Environment(\.editMode) private var editMode

    init(trip: TripPlan, day: TripDay, controller: TripController) {
        self.trip = trip
        self.day = day
        self.controller = controller
        model = TripJourneyDayModel(trip: trip, day: day)
    }

    @ViewBuilder var body: some View {
        if editMode?.wrappedValue.isEditing == true { editableRows }
        else { draggableRows }
    }

    private var draggableRows: some View {
        ForEach(model.reorderGroups) { group in
            ForEach(group.items) { item in row(item).listRowSeparator(.hidden) }
                .reorderable(collectionID: group.id)
                .onDelete { controller.removeJourneyVisits($0, items: group.items, day: day, trip: trip) }
            if let anchor = group.anchor { anchoredRow(anchor) }
        }
    }

    private func anchoredRow(_ item: TripJourneyItem) -> some View {
        row(item).listRowSeparator(.hidden)
            .swipeActions {
                if item.stop != nil {
                    Button(role: .destructive) {
                        controller.removeJourneyVisits(IndexSet(integer: 0), items: [item], day: day, trip: trip)
                    } label: { Label(TripText.delete.resource, systemImage: "trash") }
                }
            }
    }

    private var editableRows: some View {
        ForEach(model.items) { item in row(item).listRowSeparator(.hidden) }
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

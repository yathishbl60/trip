import TripLocalization
import SwiftUI
import TripDomain

struct TripEventDatesView: View {
    let draft: TripEventDraft
    let trip: TripPlan
    let controller: TripController

    var body: some View {
        Form {
            Section(draft.event.kind.startLabel) { start }
            Section { end } header: { Text(draft.event.kind.endLabel) } footer: {
                Text(TripText.localDatesAndZonesCanDifferFromItineraryDays.resource)
            }
            if let elapsed = draft.elapsedText { Section { Text(elapsed) } }
            Section {
                Toggle(TripText.manualTravelAllowance.resource, isOn: controller.eventAllowanceEnabled(draft))
                if let minutes = draft.event.travelAllowanceMinutes {
                    Stepper(TripText.minuteCount(minutes).text, value: controller.eventAllowance(draft), in: 0...1440, step: 5)
                }
            } footer: { Text(TripText.todayUsesThisAllowanceForLeaveByGuidanceIt.resource) }
        }
        .navigationTitle(TripText.dateAndTime.resource).navigationBarTitleDisplayMode(.inline)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
    }

    private var start: some View {
        TripEventBoundaryView(draft: draft, trip: trip, controller: controller,
                              title: draft.event.kind.startLabel, dayKey: \.startDayID, timeKey: \.startMinute)
    }

    private var end: some View {
        TripEventBoundaryView(draft: draft, trip: trip, controller: controller,
                              title: draft.event.kind.endLabel, dayKey: \.endDayID, timeKey: \.endMinute)
    }
}

#if DEBUG
#Preview("Multi-day dates") {
    let model = TripJourneyPreview.planner()
    let trip = model.library.trips[0]
    NavigationStack {
        TripEventDatesView(draft: TripEventDraft(trip: trip, dayID: trip.days[0].id, event: trip.events[1]),
                           trip: trip, controller: TripController(model: model))
    }
}
#Preview("Flexible event dates · large text") {
    let model = TripJourneyPreview.planner()
    let trip = model.library.trips[0]
    NavigationStack {
        TripEventDatesView(draft: TripEventDraft(trip: trip, dayID: trip.days[0].id),
                           trip: trip, controller: TripController(model: model))
    }.dynamicTypeSize(.accessibility2)
}
#endif

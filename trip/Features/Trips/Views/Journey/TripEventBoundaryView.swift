import TripLocalization
import Foundation
import SwiftUI
import TripDomain

struct TripEventBoundaryView: View {
    let draft: TripEventDraft
    let trip: TripPlan
    let controller: TripController
    let title: String
    let dayKey: WritableKeyPath<TripEvent, UUID>
    let timeKey: WritableKeyPath<TripEvent, Int?>

    var body: some View {
        Picker(TripText.itineraryDay.resource, selection: controller.eventDay(dayKey, draft: draft)) {
            ForEach(draft.days(for: dayKey, in: trip)) { day in
                Text(draft.dayLabel(day, trip: trip)).tag(day.id)
            }
        }
        Toggle(TripText.setValueTime(title.lowercased()).resource, isOn: controller.eventTimeEnabled(timeKey, draft: draft))
        if draft.event[keyPath: timeKey] != nil {
            TripEventClockView(draft: draft, arrival: timeKey == \TripEvent.endMinute, controller: controller)
        }
    }
}

#if DEBUG
#Preview("Optional departure time · large text") {
    let model = TripJourneyPreview.planner()
    let trip = model.library.trips[0]
    Form {
        TripEventBoundaryView(draft: TripEventDraft(trip: trip, dayID: trip.days[0].id, event: trip.events[0]),
                              trip: trip, controller: TripController(model: model),
                              title: "Departure", dayKey: \.startDayID, timeKey: \.startMinute)
    }.dynamicTypeSize(.accessibility2)
}
#endif

import SwiftUI
import TripDomain

struct TripStopClockReviewView: View {
    let draft: TripStopTimingDraft
    let controller: TripController

    var body: some View {
        Text(draft.calendar.timeZone.identifier).font(.caption).foregroundStyle(.secondary)
        if let clock = draft.arrivalClock, clock.candidates.count > 1 {
            TripRepeatedTimePickerView(clock: clock, selection: controller.arrivalOccurrence(draft))
        }
        if let issue = draft.arrivalClock?.issue { Label(issue, systemImage: "exclamationmark.circle").foregroundStyle(.orange) }
    }
}

#if DEBUG
#Preview("Review fixed arrival") {
    let model = TripSchedulePreview.planner()
    let trip = model.library.trips[0]
    return Form {
        TripStopClockReviewView(draft: TripStopTimingDraft(trip: trip, day: trip.days[0], stop: trip.days[0].stops[0]),
                               controller: TripController(model: model))
    }
}
#endif

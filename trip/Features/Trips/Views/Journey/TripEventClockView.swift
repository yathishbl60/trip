import TripLocalization
import Foundation
import SwiftUI
import TripDomain

struct TripEventClockView: View {
    let draft: TripEventDraft
    let arrival: Bool
    let controller: TripController
    private var clock: TripZonedDateTime { draft.clock(arrival: arrival) }

    var body: some View {
        Group {
            DatePicker(TripText.localDateAndTime.resource, selection: controller.eventLocalDate(draft, arrival: arrival),
                       displayedComponents: [.date, .hourAndMinute])
                .environment(\.timeZone, TimeZone(secondsFromGMT: 0)!)
                .environment(\.calendar, TripLocalDate.calendar(zoneID: "Etc/UTC"))
            NavigationLink(TripText.timeZoneValue(clock.zoneID.replacingOccurrences(of: "_", with: " ")).resource) {
                TripTimeZonePickerView(selection: controller.eventZone(draft, arrival: arrival))
            }
            if clock.candidates.count > 1 { occurrence }
            if let issue = clock.issue { TripWarningLabel(message: issue) }
        }
    }

    private var occurrence: some View {
        TripRepeatedTimePickerView(clock: clock, selection: controller.eventOccurrence(draft, arrival: arrival))
    }
}

#if DEBUG
#Preview("Flight endpoint · local time zone") {
    let model = TripJourneyPreview.planner()
    let trip = model.library.trips[0]
    return Form {
        TripEventClockView(draft: TripEventDraft(trip: trip, dayID: trip.days[0].id, event: trip.events[0]),
                           arrival: false, controller: TripController(model: model))
    }
}
#Preview("Repeated hour · choose occurrence") {
    NavigationStack {
        Form { TripEventClockView(draft: TripClockPreview.draft(), arrival: false,
                                  controller: TripController(model: TripJourneyPreview.planner())) }
    }
}
#Preview("Missing clock time · accessibility · dark") {
    NavigationStack {
        Form { TripEventClockView(draft: TripClockPreview.draft(gap: true), arrival: false,
                                  controller: TripController(model: TripJourneyPreview.planner())) }
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

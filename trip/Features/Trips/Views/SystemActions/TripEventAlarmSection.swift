import SwiftUI
import TripLocalization

struct TripEventAlarmSection: View {
    let draft: TripEventDraft
    let controller: TripController

    var body: some View {
        if draft.original != nil, controller.supportsTravelAlarms {
            Section {
                Button(TripText.travelAlarm.resource, systemImage: "alarm") { controller.beginAlarm(draft) }
                    .disabled(draft.hasChanges)
            } footer: {
                if draft.hasChanges { Text(TripText.saveBeforeSystemAction.resource) }
            }
        }
    }
}

#if DEBUG
#Preview("Booking alarm entry · saved booking") {
    let model = TripJourneyPreview.planner()
    Form { TripEventAlarmSection(draft: TripJourneyPreview.draft(in: model, eventIndex: 0),
                                controller: TripController(model: model)) }
}
#endif

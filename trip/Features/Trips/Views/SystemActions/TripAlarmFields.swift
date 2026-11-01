import SwiftUI
import TripDomain
import TripLocalization

struct TripAlarmFields: View {
    let session: TripSystemActionSession
    let controller: TripSystemActionsController

    var body: some View {
        if let booking = session.booking {
            Section {
                Text(booking.title).font(.headline)
                DatePicker(TripText.travelAlarmTime.resource, selection: controller.alarmDate, in: Date.now...)
                    .environment(\.timeZone, booking.timeZone)
                LabeledContent(TripText.timeZone.resource, value: booking.timeZoneID)
            } footer: { Text(TripText.travelAlarmExplanation.resource) }
            if let scheduled = session.scheduledAlarmDate {
                Section {
                    LabeledContent(TripText.scheduledTravelAlarm.resource) {
                        Text(scheduled, format: Date.FormatStyle(date: .abbreviated, time: .shortened, timeZone: booking.timeZone))
                    }
                    Button(TripText.cancelTravelAlarm.resource, role: .destructive, action: controller.cancelAlarm)
                }.environment(\.timeZone, booking.timeZone)
            }
        }
    }
}

#if DEBUG
#Preview("Travel alarm · local date and zone") {
    let model = PreviewSystemActions.model(.alarm)
    Form { TripAlarmFields(session: model.presentation!, controller: TripSystemActionsController(model: model)) }
}
#endif

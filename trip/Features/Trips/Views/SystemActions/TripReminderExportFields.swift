import SwiftUI
import TripDomain
import TripLocalization

struct TripReminderExportFields: View {
    let session: TripSystemActionSession
    let controller: TripSystemActionsController

    var body: some View {
        Section {
            if session.reminders.isEmpty {
                ContentUnavailableView(TripText.noPendingReminders.resource, systemImage: "checklist")
            }
            ForEach(session.reminders) { item in
                Toggle(item.title, isOn: controller.selected(item.id))
            }
        } footer: { Text(TripText.reminderExportExplanation.resource) }
        Section {
            Toggle(TripText.addReminderDueDate.resource, isOn: controller.usesDueDate)
            if session.usesDueDate {
                DatePicker(TripText.reminderDueDate.resource, selection: controller.dueDate)
            }
        }
    }
}

#if DEBUG
#Preview("Reminder selection · local data") {
    let model = PreviewSystemActions.model(.reminders)
    Form { TripReminderExportFields(session: model.presentation!, controller: TripSystemActionsController(model: model)) }
}
#endif

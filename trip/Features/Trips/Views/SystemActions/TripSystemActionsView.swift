import SwiftUI
import TripLocalization

struct TripSystemActionsView: View {
    let model: TripSystemActionsModel
    private var controller: TripSystemActionsController { TripSystemActionsController(model: model) }

    var body: some View {
        NavigationStack {
            Form {
                if let session = model.presentation { fields(session) }
                status
            }
            .navigationTitle(model.title).navigationBarTitleDisplayMode(.inline)
            .toolbar { tools }
        }
        .presentationDetents([.large]).presentationDragIndicator(.visible).presentationSizing(.form)
        .interactiveDismissDisabled(model.isWorking)
    }

    @ViewBuilder private func fields(_ session: TripSystemActionSession) -> some View {
        Group {
            switch session.kind {
            case .calendar: TripCalendarExportFields(session: session, controller: controller)
            case .reminders: TripReminderExportFields(session: session, controller: controller)
            case .alarm: TripAlarmFields(session: session, controller: controller)
            }
        }.disabled(model.isWorking)
    }

    @ViewBuilder private var status: some View {
        if model.isWorking { Section { ProgressView(model.actionTitle) } }
        if let error = model.presentation?.error {
            Section { Label(error, systemImage: "exclamationmark.triangle").foregroundStyle(.red) }
        }
        if let recovery = model.presentation?.recovery { Section { Text(recovery) } }
        if let result = model.presentation?.result {
            Section { Label(result, systemImage: "checkmark.circle") }
        }
    }

    @ToolbarContentBuilder private var tools: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(TripText.done.resource, action: controller.dismiss).disabled(model.isWorking)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(model.actionTitle, action: controller.perform).disabled(!model.canPerform)
        }
    }
}

#if DEBUG
#Preview("Calendar export · selected confirmed bookings") {
    TripSystemActionsView(model: PreviewSystemActions.model(.calendar))
}
#Preview("Reminders export · large text") {
    TripSystemActionsView(model: PreviewSystemActions.model(.reminders)).dynamicTypeSize(.accessibility2)
}
#Preview("Travel alarm · dark") {
    TripSystemActionsView(model: PreviewSystemActions.model(.alarm)).preferredColorScheme(.dark)
}
#endif

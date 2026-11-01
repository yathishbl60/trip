import TripLocalization
import SwiftUI
import TripDomain

struct TripEventEditorView: View {
    let draft: TripEventDraft
    let controller: TripController

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(draft.title).navigationBarTitleDisplayMode(.inline)
                #if os(iOS)
                .scrollEdgeEffectStyle(.soft, for: .top)
                #endif
                .toolbar { tools }
                .tripEventConfirmations(draft, controller: controller)
        }
        .presentationDetents([.large]).presentationDragIndicator(.visible).presentationSizing(.form)
        .interactiveDismissDisabled(draft.hasChanges)
        .tripSystemActionsSheet(controller, bookingEditor: true)
    }

    @ViewBuilder private var content: some View {
        if let trip = controller.model.library.trip(draft.tripID) {
            Form {
                TripEventDetailsView(draft: draft, controller: controller)
                schedule(trip)
                TripEventAlarmSection(draft: draft, controller: controller)
                Section(TripText.notes.resource) {
                    TextField(TripText.detailsToRemember.resource, text: controller.eventText(\.notes, draft: draft), axis: .vertical)
                        .lineLimit(3...8)
                }
                if draft.original != nil {
                    Section { Button(TripText.deleteEvent.resource, role: .destructive) { controller.requestEventDelete(draft) } }
                }
            }
        } else { ContentUnavailableView(TripText.tripUnavailable.resource, systemImage: "suitcase.rolling") }
    }

    private func schedule(_ trip: TripPlan) -> some View {
        Section {
            NavigationLink {
                TripEventDatesView(draft: draft, trip: trip, controller: controller)
            } label: {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
                    Text(TripText.dateAndTime.resource)
                    Text(draft.scheduleSummary(in: trip)).font(.subheadline).foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    @ToolbarContentBuilder private var tools: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { Button(TripText.cancel.resource) { controller.requestEventCancel(draft) } }
        ToolbarItem(placement: .confirmationAction) {
            Button(TripText.save.resource) { controller.saveEvent(draft) }
                .buttonStyle(TripButtonStyles.prominent).tint(AppTheme.accentFill).disabled(!draft.canSave)
        }
    }
}

#if DEBUG
#Preview("Add an untimed activity") {
    let model = TripJourneyPreview.planner()
    TripEventEditorView(draft: TripJourneyPreview.draft(in: model), controller: TripController(model: model))
}
#Preview("Three-night stay · large text") {
    let model = TripJourneyPreview.planner()
    TripEventEditorView(draft: TripJourneyPreview.draft(in: model, eventIndex: 1),
                        controller: TripController(model: model))
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Save failed · keep draft") {
    let model = TripJourneyPreview.planner()
    let draft = TripJourneyPreview.draft(in: model, eventIndex: 0)
    draft.error = "The trip’s days changed. Cancel and reopen this event to use the latest dates."
    return TripEventEditorView(draft: draft, controller: TripController(model: model))
}
#Preview("Overnight flight · both dates and times") {
    let model = TripJourneyPreview.planner()
    let draft = TripJourneyPreview.draft(in: model, eventIndex: 0)
    draft.setDay(model.library.trips[0].days[1].id, at: \.endDayID)
    draft.set(1_320, at: \.startMinute)
    draft.set(420, at: \.endMinute)
    return TripEventEditorView(draft: draft, controller: TripController(model: model))
}
#Preview("Discard edited details") {
    let model = TripJourneyPreview.planner()
    let draft = TripJourneyPreview.draft(in: model, eventIndex: 1)
    draft.setText("A different hotel", at: \.title)
    draft.isDiscarding = true
    return TripEventEditorView(draft: draft, controller: TripController(model: model))
}
#endif

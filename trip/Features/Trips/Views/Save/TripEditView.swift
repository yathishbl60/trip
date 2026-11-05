import TripLocalization
import SwiftUI

struct TripEditView: View {
    let draft: TripEditDraft
    let controller: TripController
    @FocusState private var nameFocused: Bool

    var body: some View {
        NavigationStack {
            form
        }
        .presentationDetents([.large])
        .presentationSizing(.form)
        .presentationContentInteraction(.scrolls)
        .presentationDragIndicator(.visible)
        .tripDraftDismissal(draft, controller: controller) { controller.cancelEdit(draft) }
        .onAppear { nameFocused = draft.tripID == nil }
    }

    private var form: some View {
        Form {
            tripDetails
            notes
            if let error = draft.error { errorMessage(error) }
        }
        .navigationTitle(draft.navigationTitle)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { tools }
    }

    private var notes: some View {
        Section(TripText.notes.resource) {
            TextField(TripText.reservationsAndReminders.resource, text: controller.draftNotes(draft),
                      axis: .vertical).lineLimit(3...6)
        }
    }

    private func errorMessage(_ error: String) -> some View {
        TripWarningLabel(message: error)
    }

    private var tripDetails: some View {
        Section {
            TextField(TripText.tripName.resource, text: controller.draftTitle(draft)).font(.title3.weight(.semibold)).focused($nameFocused)
                .textInputAutocapitalization(.words).submitLabel(.done)
                .onSubmit { nameFocused = false }
            DatePicker(TripText.departure.resource, selection: controller.draftDate(draft), displayedComponents: .date)
                .environment(\.timeZone, draft.calendar.timeZone).environment(\.calendar, draft.calendar)
            NavigationLink(TripText.timeZoneValue(draft.timeZoneID.replacingOccurrences(of: "_", with: " ")).resource) {
                TripTimeZoneReviewView(draft: draft, controller: controller)
            }
        } footer: {
            if let message = draft.validationMessage { TripWarningLabel(message: message) }
        }
    }

    @ToolbarContentBuilder private var tools: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(TripText.cancel.resource) {
                controller.requestDiscard(draft) { controller.cancelEdit(draft) }
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(TripText.save.resource) { controller.saveEdit(draft) }
                .buttonStyle(TripButtonStyles.prominent).disabled(!draft.canSave)
                .tint(AppTheme.accentFill)
        }
    }
}

#if DEBUG
#Preview("New trip") {
    TripEditView(draft: TripEditDraft(), controller: TripController(model: PreviewFixtures.emptyTripPlanner()))
}
#Preview("Edit trip · dark") {
    let model = PreviewFixtures.tripPlanner()
    TripEditView(draft: TripEditDraft(trip: model.library.trips[0]), controller: TripController(model: model))
        .preferredColorScheme(.dark)
}
#Preview("Long name · validation") {
    let draft = TripEditDraft()
    draft.title = String(repeating: "A long journey ", count: 10)
    return TripEditView(draft: draft, controller: TripController(model: PreviewFixtures.emptyTripPlanner()))
        .dynamicTypeSize(.accessibility2)
}
#Preview("Keep or discard trip edits") {
    let model = PreviewFixtures.tripPlanner()
    let draft = TripEditDraft(trip: model.library.trips[0])
    draft.notes += "\nA reminder to keep."
    draft.isDiscarding = true
    return TripEditView(draft: draft, controller: TripController(model: model))
}
#endif

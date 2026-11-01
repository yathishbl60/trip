import SwiftUI
import TripLocalization

extension View {
    func tripDraftDismissal(_ draft: some TripDiscardableDraft, controller: TripController,
                           discard: @escaping () -> Void) -> some View {
        interactiveDismissDisabled(draft.hasUnsavedChanges)
            .confirmationDialog(TripText.discardYourChanges.resource, isPresented: controller.discarding(draft),
                                titleVisibility: .visible) {
                Button(TripText.discardChanges.resource, role: .destructive, action: discard)
                Button(TripText.cancel.resource, role: .cancel) {}
            }
    }
}

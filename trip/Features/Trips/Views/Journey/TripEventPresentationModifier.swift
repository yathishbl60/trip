import TripLocalization
import SwiftUI

extension View {
    func tripEventSheet(_ controller: TripController) -> some View {
        sheet(item: controller.eventDraft) { draft in
            TripEventEditorView(draft: draft, controller: controller)
        }
    }

    func tripEventConfirmations(_ draft: TripEventDraft, controller: TripController) -> some View {
        confirmationDialog(draft.deletionMessage, isPresented: controller.eventDeletion(draft),
                           titleVisibility: .visible) {
            Button(TripText.deleteEvent.resource, role: .destructive) { controller.deleteEvent(draft) }
        }
        .confirmationDialog(TripText.discardYourChanges.resource, isPresented: controller.eventDiscarding(draft),
                            titleVisibility: .visible) {
            Button(TripText.discardChanges.resource, role: .destructive) { controller.cancelEvent(draft) }
        }
        .alert(TripText.couldnTSaveEvent.resource, isPresented: controller.eventFailure(draft)) {
            Button(TripText.ok.resource, role: .cancel) {}
        } message: { Text(draft.error ?? TripText.reviewTheEventDetailsAndTryAgain.text) }
    }
}

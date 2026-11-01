import SwiftUI

extension TripController {
    func requestDiscard(_ draft: some TripDiscardableDraft, cancel: () -> Void) {
        if draft.hasUnsavedChanges { draft.isDiscarding = true }
        else { cancel() }
    }

    func discarding(_ draft: some TripDiscardableDraft) -> Binding<Bool> {
        Binding(get: { draft.isDiscarding }, set: { draft.isDiscarding = $0 })
    }
}

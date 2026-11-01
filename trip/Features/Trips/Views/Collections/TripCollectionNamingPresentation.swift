import TripLocalization
import SwiftUI

extension View {
    func collectionNamingAlert(_ controller: TripController, tripID: UUID) -> some View {
        let draft = controller.model.presentation.collectionDraft
        return alert(draft?.navigationTitle ?? TripText.collection.text, isPresented: controller.collectionNaming(in: tripID),
                     presenting: draft) { draft in
            TextField(TripText.collectionName.resource, text: controller.collectionTitle(draft))
            Button(TripText.save.resource) { controller.commitCollection(draft) }.disabled(!draft.canSave)
            Button(TripText.cancel.resource, role: .cancel) { }
        } message: { draft in
            if let message = draft.validationMessage { Text(message) }
        }
    }
}

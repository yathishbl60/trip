import TripLocalization
import SwiftUI
import TripDomain

extension View {
    func tripChecklistNamingAlert(_ controller: TripChecklistController, tripID: UUID) -> some View {
        let draft = controller.model.draft
        return alert(draft?.navigationTitle ?? TripText.checklist.text, isPresented: controller.checklistNaming(in: tripID),
                     presenting: draft) { draft in
            TextField(TripText.item.resource, text: controller.checklistTitle(draft))
            Button(TripText.save.resource) { controller.saveChecklistItem(draft) }.disabled(!draft.canSave)
            Button(TripText.cancel.resource, role: .cancel) { }
        } message: { _ in
            Text(TripText.nameAPackingItemOrTaskUpToValue(TripText.number(TripLimits.titleCharacters)).resource)
        }
    }
}

import SwiftUI

extension View {
    func tripEditSheet(_ controller: TripController, savingPlace: Bool = false) -> some View {
        sheet(item: controller.editDraft(savingPlace: savingPlace)) { draft in
            TripEditView(draft: draft, controller: controller)
        }
    }
}

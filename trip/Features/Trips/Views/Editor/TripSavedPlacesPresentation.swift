import SwiftUI

extension View {
    func tripSavedPlaceSheet(_ controller: TripController, forAssistant: Bool = false) -> some View {
        sheet(item: controller.savedPlacePicker(forAssistant: forAssistant)) { picker in
            TripSavedPlacesView(picker: picker, controller: controller)
        }
    }
}

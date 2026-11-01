import SwiftUI

extension View {
    func tripNativeServiceSheets(_ controller: TripController) -> some View {
        tripBookingImportSheet(controller)
            .tripSystemActionsSheet(controller)
            .tripWeatherSheet(controller)
    }
}

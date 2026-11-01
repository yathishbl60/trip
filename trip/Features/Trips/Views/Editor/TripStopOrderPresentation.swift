import SwiftUI

extension View {
    func tripStopOrderSheet(_ controller: TripController) -> some View {
        sheet(item: controller.stopOrder) { draft in
            TripStopOrderView(draft: draft, controller: controller)
        }
    }
}

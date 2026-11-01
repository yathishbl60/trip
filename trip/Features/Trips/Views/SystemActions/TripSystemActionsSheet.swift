import SwiftUI

struct TripSystemActionsSheet: ViewModifier {
    let controller: TripController
    let bookingEditor: Bool

    func body(content: Content) -> some View {
        content.sheet(item: controller.systemActionPresentation(bookingEditor: bookingEditor)) { _ in
            TripSystemActionsView(model: controller.model.systemActions)
        }
    }
}

extension View {
    func tripSystemActionsSheet(_ controller: TripController, bookingEditor: Bool = false) -> some View {
        modifier(TripSystemActionsSheet(controller: controller, bookingEditor: bookingEditor))
    }
}

#if DEBUG
#Preview("System action sheet · local trip") {
    let model = PreviewFixtures.tripPlanner()
    Text("Trip").tripSystemActionsSheet(TripController(model: model))
}
#endif

import SwiftUI
import TripLocalization

struct AppNavigationFeedback: ViewModifier {
    let controller: AppController

    func body(content: Content) -> some View {
        content.alert(TripText.tripsUnavailable.resource, isPresented: controller.hasNavigationNotice) {
            Button(TripText.ok.resource, role: .cancel) {}
        } message: {
            Text(controller.model.navigation.notice ?? "")
        }
    }
}

#if DEBUG
#Preview("Unavailable trip link · local feedback") {
    let model = PreviewFixtures.app()
    model.navigation.notice = TripText.thisTripIsNoLongerAvailable.text
    return Text(TripText.trips.resource)
        .modifier(AppNavigationFeedback(controller: AppController(model: model)))
}
#endif

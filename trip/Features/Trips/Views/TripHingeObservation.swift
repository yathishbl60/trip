import SwiftUI
#if DEBUG
import TripDomain
#endif

extension EnvironmentValues {
    @Entry var tripHingePartiallyOpen = false
}

/// Only destinations with a folded layout subscribe. Angle updates within a pose require no layout work.
struct TripHingeObservation: ViewModifier {
    @State private var partiallyOpen = false

    func body(content: Content) -> some View {
        content
            .environment(\.tripHingePartiallyOpen, partiallyOpen)
            .onHingeChange { _, context in
                let open = context.hinge?.status == .partiallyOpen
                if open != partiallyOpen { partiallyOpen = open }
            }
    }
}

#if DEBUG
#Preview("Trip hinge observation · Today") {
    let model = TripTodayPreview.planner()
    NavigationStack {
        TripTodayView(tripID: model.library.trips[0].id, controller: TripController(model: model),
                      previewDate: TripTodayPreview.now)
            .modifier(TripHingeObservation())
    }
}
#endif

#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI

struct DirectionsRouteChoicesView: View {
    let controller: DirectionsController
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: DirectionsSpacing.medium) {
            routePicker
            if let route = controller.model.selectedRoute {
                DirectionsSummaryView(estimate: route.estimate, route: route, controller: controller)
            }
        }
    }

    @ViewBuilder private var routePicker: some View {
        if usesMenu { picker(showingLabels: true).pickerStyle(.menu) }
        else { picker(showingLabels: false).pickerStyle(.segmented) }
    }

    private var usesMenu: Bool {
        typeSize.isAccessibilitySize || controller.model.presentation.usesLargeText
            || controller.model.routes.count > 2 || hasDuplicateDurations
    }

    private var hasDuplicateDurations: Bool {
        let durations = controller.model.routes.map { $0.estimate.durationText }
        return Set(durations).count != durations.count
    }

    private func picker(showingLabels: Bool) -> some View {
        Picker(TripText.route.resource, selection: controller.selectedRoute) {
            ForEach(controller.model.routes) { route in
                let duration = route.estimate.durationText
                let label = controller.model.choiceLabel(for: route)
                Text(showingLabels ? "\(duration) · \(label)" : duration)
                    .accessibilityLabel("\(duration), \(label)")
                    .tag(Optional(route.id))
            }
        }
        .accessibilityHint(TripText.showsThisRouteOnTheMap.resource)
    }
}

#if DEBUG
#Preview("Native alternative routes", traits: .sizeThatFitsLayout) {
    DirectionsRouteChoicesView(controller: DirectionsController(model: DirectionsPreviewFixtures.ready())).padding()
}
#Preview("Accessible route choices", traits: .sizeThatFitsLayout) {
    let model = DirectionsPreviewFixtures.ready()
    model.presentation.usesLargeText = true
    return DirectionsRouteChoicesView(controller: DirectionsController(model: model))
        .dynamicTypeSize(.accessibility2).padding()
}
#endif
#endif

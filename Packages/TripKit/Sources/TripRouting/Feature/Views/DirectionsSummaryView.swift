#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI

struct DirectionsSummaryView: View {
    let estimate: DirectionsEstimate
    let route: DirectionsRoute?
    let controller: DirectionsController

    var body: some View {
        VStack(alignment: .leading, spacing: DirectionsSpacing.medium) {
            DirectionsEstimateView(estimate: estimate, routeLabel: route.map { controller.model.label(for: $0) },
                                   hasTolls: route?.hasTolls == true, isTransit: route == nil && controller.model.mode == .transit)
                .animation(controller.model.presentation.animation, value: estimate.travelTime)
            action.labelStyle(.titleAndIcon)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DirectionsSpacing.small)
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder private var action: some View {
        if let route, !route.steps.isEmpty {
            Button(TripText.steps.resource, systemImage: "list.bullet", action: controller.showSteps)
                .buttonStyle(.bordered)
        } else {
            DirectionsMapsButton(controller: controller)
        }
    }
}

#if DEBUG
#Preview("Route card · screenshot toll case, local") {
    let model = DirectionsPreviewFixtures.tollRoutes()
    if let estimate = model.estimate {
        List {
            DirectionsSummaryView(estimate: estimate, route: model.selectedRoute,
                                  controller: DirectionsController(model: model))
        }.frame(width: 393, height: 600).preferredColorScheme(.dark)
    }
}
#Preview("Route summary · accessibility, local") {
    let model = DirectionsPreviewFixtures.tollRoutes()
    if let estimate = model.estimate {
        List {
            DirectionsSummaryView(estimate: estimate, route: model.selectedRoute,
                                  controller: DirectionsController(model: model))
        }.frame(width: 320, height: 600).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
    }
}
#endif
#endif

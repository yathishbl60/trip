#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI

struct DirectionsResultsView: View {
    let controller: DirectionsController

    var body: some View {
        VStack(spacing: 12) {
            if controller.model.estimate != nil {
                results.disabled(controller.model.status != .ready)
                if controller.model.isLoading { ProgressView(TripText.updatingRoutes.resource).font(.subheadline) }
            } else if controller.model.isLoading {
                ProgressView(controller.model.compactDescription)
                    .frame(maxWidth: .infinity, minHeight: 96)
            } else if controller.model.status == .choosingOrigin {
                chooseOrigin
            } else if case .unavailable(let message) = controller.model.status {
                unavailable(message)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(controller.model.presentation.animation, value: controller.model.status)
    }

    private var chooseOrigin: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(TripText.whereAreYouStarting.resource).font(.headline)
            Button(TripText.chooseAPlace.resource, systemImage: "magnifyingglass", action: controller.changeOrigin)
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 8)
    }

    @ViewBuilder private var results: some View {
        if controller.model.routes.count > 1 {
            DirectionsRouteChoicesView(controller: controller)
        } else if let estimate = controller.model.estimate {
            DirectionsSummaryView(estimate: estimate, route: controller.model.selectedRoute, controller: controller)
        }
    }

    private func unavailable(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(TripText.directionsUnavailable.resource, systemImage: "map").font(.headline)
            Text(message).font(.subheadline).foregroundStyle(.secondary)
            Button(TripText.tryAgain.resource, action: controller.retry).buttonStyle(.bordered)
            DirectionsMapsButton(controller: controller)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}

#if DEBUG
#Preview("Route choices", traits: .sizeThatFitsLayout) {
    DirectionsResultsView(controller: DirectionsController(model: DirectionsPreviewFixtures.ready())).padding()
}
#Preview("No route", traits: .sizeThatFitsLayout) {
    DirectionsResultsView(controller: DirectionsController(model: DirectionsPreviewFixtures.unavailable())).padding()
}
#Preview("Loading routes", traits: .sizeThatFitsLayout) {
    let model = DirectionsPreviewFixtures.ready()
    model.clearResults()
    model.status = .loading
    return DirectionsResultsView(controller: DirectionsController(model: model)).padding()
}
#Preview("No route · accessibility", traits: .sizeThatFitsLayout) {
    DirectionsResultsView(controller: DirectionsController(model: DirectionsPreviewFixtures.unavailable()))
        .padding().dynamicTypeSize(.accessibility3)
}
#Preview("Starting point needed", traits: .sizeThatFitsLayout) {
    DirectionsResultsView(controller: DirectionsController(model: DirectionsPreviewFixtures.withoutLocation())).padding()
}
#endif
#endif

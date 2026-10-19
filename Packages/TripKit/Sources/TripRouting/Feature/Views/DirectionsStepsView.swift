#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI
import Foundation

struct DirectionsStepsView: View {
    let controller: DirectionsController
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List { routeSteps }
            .navigationTitle(TripText.routeSteps.resource)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button(TripText.done.resource) { dismiss() } } }
            .safeAreaInset(edge: .bottom) {
                DirectionsMapsButton(controller: controller).padding()
                    .frame(maxWidth: .infinity).background(.bar)
            }
        }
    }

    @ViewBuilder private var routeSteps: some View {
        if let route = controller.model.selectedRoute {
            Section(route.name) { ForEach(route.notices, id: \.self) { Text($0) } }
            ForEach(Array(route.steps.enumerated()), id: \.element.id) { index, step in
                instruction(step, number: index + 1)
            }
        }
    }

    private func instruction(_ step: DirectionsStep, number: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number, format: .number).font(.subheadline.monospacedDigit().weight(.semibold))
                .frame(minWidth: 32, minHeight: 32).background(.quaternary, in: .circle)
                .accessibilityLabel(TripText.stepValue(TripText.number(number)).resource)
            VStack(alignment: .leading, spacing: 6) {
                Text(step.instruction).font(.headline)
                if step.distance > 0 {
                    Text(Measurement(value: step.distance, unit: UnitLength.meters), format: .measurement(width: .abbreviated))
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                if let notice = step.notice { Text(notice).font(.caption).foregroundStyle(.secondary) }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Route instructions · local fixture") {
    DirectionsStepsView(controller: DirectionsController(model: DirectionsPreviewFixtures.ready()))
}
#Preview("Route instructions · large text, dark") {
    DirectionsStepsView(controller: DirectionsController(model: DirectionsPreviewFixtures.ready()))
        .dynamicTypeSize(.accessibility3).preferredColorScheme(.dark)
}
#endif
#endif

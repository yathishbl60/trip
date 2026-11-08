#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI
import Foundation

struct DirectionsStepsView: View {
    let controller: DirectionsController
    @ScaledMetric(relativeTo: .subheadline) private var badgeSize = 32.0

    var body: some View {
        let compact = controller.model.presentation.isCompact
        return List { routeSteps }
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .safeAreaInset(edge: .bottom) {
                if !compact {
                    DirectionsMapsButton(controller: controller).padding()
                        .frame(maxWidth: .infinity).background(.bar)
                }
            }
            .opacity(compact ? 0 : 1)
            .allowsHitTesting(!compact)
            .accessibilityHidden(compact)
            .navigationTitle(TripText.routeSteps.resource)
            .navigationBarTitleDisplayMode(.inline)
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
        HStack(alignment: .top, spacing: DirectionsSpacing.medium) {
            Text(number, format: .number).font(.subheadline.monospacedDigit().weight(.semibold))
                .frame(minWidth: badgeSize, minHeight: badgeSize).background(.quaternary, in: .circle)
                .accessibilityLabel(TripText.stepValue(TripText.number(number)).resource)
            VStack(alignment: .leading, spacing: DirectionsSpacing.tight) {
                Text(step.instruction).font(.headline)
                if step.distance > 0 {
                    Text(Measurement(value: step.distance, unit: UnitLength.meters), format: .measurement(width: .abbreviated))
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                if let notice = step.notice { Text(notice).font(.caption).foregroundStyle(.secondary) }
            }
        }
        .padding(.vertical, DirectionsSpacing.tight)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Route instructions · local fixture") {
    let model = DirectionsPreviewFixtures.ready()
    model.showSteps()
    return DirectionsSheetView(model: model)
}
#Preview("Route instructions · large text, dark") {
    NavigationStack { DirectionsStepsView(controller: DirectionsController(model: DirectionsPreviewFixtures.ready())) }
        .dynamicTypeSize(.accessibility3).preferredColorScheme(.dark)
}
#endif
#endif

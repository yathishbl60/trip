#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI

public struct DirectionsSheetView: View {
    let controller: DirectionsController
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize

    public init(model: DirectionsModel) { controller = DirectionsController(model: model) }

    public var body: some View {
        content
            #if os(iOS)
            .presentationDetents(controller.model.presentation.detents, selection: controller.detent)
            .presentationPlacement(.leading)
            .presentationCompactAdaptation(horizontal: .automatic, vertical: .none)
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.resizes)
            .presentationBackgroundInteraction(.enabled(upThrough: .large))
            .interactiveDismissDisabled(!controller.model.configuration.allowsInteractiveDismissal)
            #endif
            .onChange(of: typeSize, initial: true) { updateAccessibility() }
            .onChange(of: reduceMotion) { updateAccessibility() }
    }

    private var content: some View {
        NavigationStack {
            Group {
                if controller.model.presentation.isCompact { Color.clear }
                else { DirectionsExpandedView(controller: controller) }
            }
            .navigationTitle(TripText.directions.resource)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { DirectionsToolbar(controller: controller) }
            .navigationDestination(isPresented: controller.readingSteps) { DirectionsStepsView(controller: controller) }
            .navigationDestination(isPresented: controller.editingRoute) { editor }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .reportingDirectionsFrame(to: controller)
    }

    @ViewBuilder private var editor: some View {
        if controller.model.presentation.auxiliary?.screen == .stops {
            DirectionsStopsView(controller: controller)
        } else if let session = controller.model.presentation.placePicker {
            DirectionsStopPickerView(controller: controller, session: session)
        }
    }

    private func updateAccessibility() {
        controller.accessibility(largeText: typeSize.isAccessibilitySize, reduceMotion: reduceMotion)
    }
}

#if DEBUG
#Preview("Directions · local alternatives") {
    DirectionsSheetView(model: DirectionsPreviewFixtures.ready())
}
#if os(iOS)
#Preview("Collapsed leading sheet · landscape, local route", traits: .landscapeLeft) {
    @Previewable @State var model = DirectionsPreviewFixtures.compact()
    Color.secondary.opacity(0.15)
        .sheet(isPresented: Binding(get: { model.isPresented }, set: { if !$0 { model.dismiss() } })) {
            DirectionsSheetView(model: model)
        }
}
#endif
#Preview("Directions unavailable · dark") {
    DirectionsSheetView(model: DirectionsPreviewFixtures.unavailable())
        .preferredColorScheme(.dark)
}
#Preview("Directions · accessibility") {
    DirectionsSheetView(model: DirectionsPreviewFixtures.ready())
        .dynamicTypeSize(.accessibility2)
}
#Preview("Directions · long destination, dark") {
    let model = DirectionsPreviewFixtures.ready()
    model.destination = DirectionsPreviewFixtures.longDestination
    return DirectionsSheetView(model: model).preferredColorScheme(.dark)
}
#Preview("Screenshot regression · toll route sheet, local") {
    let model = DirectionsPreviewFixtures.tollRoutes()
    model.presentation.detent = .large
    return DirectionsSheetView(model: model)
        .frame(width: 393, height: 780).preferredColorScheme(.dark)
}
#endif
#endif

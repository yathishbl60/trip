#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI

public struct DirectionsSheetView: View {
    let controller: DirectionsController
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.verticalSizeClass) private var verticalSize
    @Environment(\.horizontalSizeClass) private var horizontalSize
    @Environment(\.dynamicTypeSize) private var typeSize

    init(controller: DirectionsController) { self.controller = controller }
    public init(model: DirectionsModel) { controller = DirectionsController(model: model) }

    public var body: some View {
        content
            .presentationSizing(.form)
            .presentationCornerRadius(controller.model.presentation.compactCornerRadius)
            .presentationDetents(controller.model.presentation.detents, selection: controller.detent)
            .interactiveDismissDisabled(!controller.model.configuration.allowsInteractiveDismissal)
            .sheet(item: controller.auxiliary, content: auxiliary)
            .onChange(of: typeSize, initial: true) { updateAccessibility() }
            .onChange(of: verticalSize) { updateAccessibility() }
            .onChange(of: horizontalSize) { updateAccessibility() }
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .global) }, action: controller.sheetFrameChanged)
        .presentationDragIndicator(.visible)
        .presentationContentInteraction(.resizes)
        .presentationBackgroundInteraction(.enabled(upThrough: DirectionsPresentationModel.standard))
    }

    @ViewBuilder private func auxiliary(_ destination: DirectionsAuxiliary) -> some View {
        switch destination.screen {
        case .steps: DirectionsStepsView(controller: controller)
        case .stops: DirectionsStopsView(controller: controller)
        case .options: DirectionsOptionsView(controller: controller)
        case .placePicker:
            if let session = controller.model.presentation.placePicker {
                NavigationStack {
                    DirectionsStopPickerView(controller: controller, session: session, showsCancel: true)
                }
            }
        }
    }

    private func updateAccessibility() {
        controller.accessibility(largeText: typeSize.isAccessibilitySize, reduceMotion: reduceMotion,
                                 compactHeight: verticalSize == .compact, regularWidth: horizontalSize == .regular)
    }
}

#if DEBUG
#Preview("Directions · local alternatives") {
    DirectionsSheetView(controller: DirectionsController(model: DirectionsPreviewFixtures.ready()))
}
#Preview("Compact directions") {
    DirectionsSheetView(controller: DirectionsController(model: DirectionsPreviewFixtures.compact()))
}
#Preview("Directions unavailable · dark") {
    DirectionsSheetView(controller: DirectionsController(model: DirectionsPreviewFixtures.unavailable()))
        .preferredColorScheme(.dark)
}
#Preview("Directions · accessibility") {
    DirectionsSheetView(controller: DirectionsController(model: DirectionsPreviewFixtures.ready()))
        .dynamicTypeSize(.accessibility2)
}
#Preview("Directions · long destination, dark") {
    let model = DirectionsPreviewFixtures.ready()
    model.destination = DirectionsPreviewFixtures.longDestination
    return DirectionsSheetView(controller: DirectionsController(model: model)).preferredColorScheme(.dark)
}
#Preview("Screenshot regression · toll route sheet, local") {
    let model = DirectionsPreviewFixtures.tollRoutes()
    model.presentation.detent = .large
    return DirectionsSheetView(controller: DirectionsController(model: model))
        .frame(width: 393, height: 780).preferredColorScheme(.dark)
}
#endif
#endif

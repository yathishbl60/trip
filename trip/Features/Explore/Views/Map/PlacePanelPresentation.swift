import SwiftUI

struct PlacePanelPresentation: ViewModifier {
    let controller: PlaceController
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    func body(content: Content) -> some View {
        content
            #if os(iOS)
            .presentationPlacement(.leading)
            .presentationCompactAdaptation(horizontal: .automatic, vertical: .none)
            .presentationDetents(controller.model.selection.presentation.detents, selection: controller.detailDetent)
            .presentationContentInteraction(controller.allowsCollapsedDetails ? .resizes : .scrolls)
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled(upThrough: .large))
            .onChange(of: layout, initial: true) { controller.updatePanelLayout(layout) }
            #endif
    }

    private var layout: PlacePanelLayout {
        PlacePanelLayout(largeText: typeSize.isAccessibilitySize, compactHeight: verticalSizeClass == .compact,
                         allowsCompact: controller.allowsCollapsedDetails)
    }
}

#if DEBUG
#Preview("Map panel · native presentation") {
    @Previewable @State var presented = true
    Color.clear.sheet(isPresented: $presented) {
        Text("Places").modifier(PlacePanelPresentation(controller: PlaceController(model: PreviewFixtures.explore())))
    }
}
#endif

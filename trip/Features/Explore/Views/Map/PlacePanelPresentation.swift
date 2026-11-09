import SwiftUI

struct PlacePanelPresentation: ViewModifier {
    let controller: PlaceController
    @Environment(\.dynamicTypeSize) private var typeSize

    func body(content: Content) -> some View {
        content
            #if os(iOS)
            .presentationPlacement(.leading)
            .presentationCompactAdaptation(horizontal: .automatic, vertical: .none)
            .presentationDetents(controller.model.selection.presentation.detents, selection: controller.detailDetent)
            .presentationContentInteraction(.resizes)
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled(upThrough: .large))
            .onChange(of: typeSize, initial: true) { controller.detailAccessibilityChanged(typeSize) }
            #endif
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

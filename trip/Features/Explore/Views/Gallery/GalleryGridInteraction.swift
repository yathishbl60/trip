import CoreGraphics
import SwiftUI

struct GalleryGridInteraction: ViewModifier {
    let controller: PlaceGalleryController
    let size: CGSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @GestureState private var isPinching = false

    func body(content: Content) -> some View {
        content
            .scrollDisabled(isPinching)
            .onDisappear(perform: controller.suspendGrid)
            .simultaneousGesture(pinch)
            .onChange(of: isPinching) { _, active in
                if !active { controller.finishPinch(reduceMotion: reduceMotion) }
            }
            .onChange(of: size) { old, _ in controller.resizeGrid(from: old) }
            .onChange(of: controller.model.focusedID) { _, _ in
                controller.revealFocusedPhoto()
            }
            .toolbar { GalleryGridToolbar(controller: controller, size: size) }
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
    }

    private var pinch: some Gesture {
        MagnifyGesture()
            .updating($isPinching) { _, active, _ in active = true }
            .onChanged { value in
                controller.magnify(value, size: size, reduceMotion: reduceMotion)
            }
            .onEnded { _ in controller.finishPinch(reduceMotion: reduceMotion) }
    }
}

#Preview("Grid interaction · native menu") {
    @Previewable @Namespace var namespace
    NavigationStack {
        PlaceGalleryGrid(controller: PlaceGalleryController(model: PlaceGalleryModel()), namespace: namespace)
    }
}

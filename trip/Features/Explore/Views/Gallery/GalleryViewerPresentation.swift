import SwiftUI

struct GalleryViewerPresentation: ViewModifier {
    let placeName: String
    let controller: PlaceGalleryController
    let namespace: Namespace.ID
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .navigationDestination(isPresented: controller.viewerPresented) {
                GalleryViewerView(placeName: placeName, controller: controller)
                    .navigationTransition(transition)
            }
    }

    private var transition: AnyNavigationTransition {
        if reduceMotion { return AnyNavigationTransition(.crossFade) }
        return AnyNavigationTransition(.zoom(sourceID: controller.model.focusedID ?? "", in: namespace))
    }
}

#Preview("Gallery presentation · local samples") {
    PlaceGalleryView(placeName: "Bangkok", controller: PlaceGalleryController(model: PlaceGalleryModel()))
}

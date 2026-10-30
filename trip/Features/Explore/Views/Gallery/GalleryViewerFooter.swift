import SwiftUI
import TripLocalization

struct GalleryViewerFooter: View {
    let controller: PlaceGalleryController
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        GalleryFilmstrip(controller: controller)
            .frame(maxWidth: 540)
            .padding(.bottom, 8)
            .opacity(isVisible ? 1 : 0)
            .allowsHitTesting(isVisible)
            .accessibilityHidden(!isVisible)
    }

    private var isVisible: Bool { !controller.model.hidesControls && verticalSizeClass != .compact }
}

#Preview("Viewer footer · share sample") {
    let model = PlaceGalleryModel()
    model.open(model.photos[0])
    return GalleryViewerFooter(controller: PlaceGalleryController(model: model))
}

#Preview("Viewer footer · compact landscape") {
    let model = PlaceGalleryModel()
    model.open(model.photos[0])
    return GalleryViewerFooter(controller: PlaceGalleryController(model: model))
        .environment(\.verticalSizeClass, .compact)
}

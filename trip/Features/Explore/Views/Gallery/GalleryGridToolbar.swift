import CoreGraphics
import SwiftUI
import TripLocalization

struct GalleryGridToolbar: ToolbarContent {
    let controller: PlaceGalleryController
    let size: CGSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu(TripText.galleryViewOptions.resource, systemImage: "slider.horizontal.3") {
                Button(TripText.zoomIn.resource, systemImage: "plus.magnifyingglass") {
                    controller.zoom(1, size: size, reduceMotion: reduceMotion)
                }.disabled(controller.model.grid.density >= 2)
                Button(TripText.zoomOut.resource, systemImage: "minus.magnifyingglass") {
                    controller.zoom(-1, size: size, reduceMotion: reduceMotion)
                }.disabled(controller.model.grid.density <= 0)
                Toggle(TripText.galleryAspectRatio.resource, isOn: aspectRatio)
                Divider()
                Button(TripText.galleryAboutSamples.resource, systemImage: "info.circle", action: controller.showInformation)
            }
        }
    }

    private var aspectRatio: Binding<Bool> {
        Binding(get: { controller.model.grid.usesAspectRatio }, set: { _ in
            controller.toggleAspectRatio(size: size, reduceMotion: reduceMotion)
        })
    }
}

#Preview("Gallery options · accessibility") {
    @Previewable @Namespace var namespace
    NavigationStack {
        PlaceGalleryGrid(controller: PlaceGalleryController(model: PlaceGalleryModel()), namespace: namespace)
    }.dynamicTypeSize(.accessibility2)
}

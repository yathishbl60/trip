import SwiftUI
import TripLocalization

struct GalleryPhotoPage: View {
    let photo: GalleryPhoto
    let controller: PlaceGalleryController
    @State private var zoom = GalleryPhotoZoomModel()

    var body: some View {
        GeometryReader { geometry in
            Image(photo.imageName).resizable().scaledToFit()
                .scaleEffect(zoom.scale).offset(zoom.offset)
                .frame(width: geometry.size.width, height: geometry.size.height).clipped()
                .contentShape(.rect)
                .modifier(GalleryPhotoInteraction(photo: photo, controller: zoomController,
                                                   gallery: controller, size: geometry.size))
                .modifier(GalleryPhotoAccessibility(photo: photo, zoom: zoom, gallery: controller, size: geometry.size))
        }
        .onChange(of: controller.model.focusedID) { _, id in zoomController.resetUnlessFocused(id, photoID: photo.id) }
        .onChange(of: zoom.scale > 1) { _, zoomed in
            controller.setZoomed(zoomed, photoID: photo.id)
        }
        .onDisappear(perform: zoomController.reset)
        .accessibilityHidden(controller.model.focusedID != photo.id)
    }

    private var zoomController: GalleryPhotoZoomController { GalleryPhotoZoomController(model: zoom) }
}

#Preview("Photo · landscape") {
    let model = PlaceGalleryModel()
    model.open(model.photos[0])
    return GalleryPhotoPage(photo: model.photos[0], controller: PlaceGalleryController(model: model))
}
#Preview("Photo · portrait, dark") {
    let model = PlaceGalleryModel()
    model.open(model.photos[11])
    return GalleryPhotoPage(photo: model.photos[11], controller: PlaceGalleryController(model: model))
        .preferredColorScheme(.dark)
}

#Preview("Photo · short window") {
    let model = PlaceGalleryModel()
    model.open(model.photos[0])
    return GalleryPhotoPage(photo: model.photos[0], controller: PlaceGalleryController(model: model))
        .frame(width: 680, height: 300)
}

import CoreGraphics
import SwiftUI

struct GalleryGridContent: View {
    let controller: PlaceGalleryController
    let namespace: Namespace.ID

    var body: some View {
        GalleryGridLayout(density: controller.model.grid.density,
                          ratios: controller.model.photos.map(\.aspectRatio),
                          usesAspectRatio: controller.model.grid.usesAspectRatio) {
            ForEach(controller.model.photos) { photo in
                GalleryGridCell(photo: photo, controller: controller, namespace: namespace)
                    .id(photo.id)
            }
        }
        .coordinateSpace(name: "galleryGridContent")
        .scrollTargetLayout()
    }
}

#Preview("Grid content · large photos") {
    @Previewable @Namespace var namespace
    let model = PlaceGalleryModel()
    model.grid.density = 2
    return ScrollView {
        GalleryGridContent(controller: PlaceGalleryController(model: model), namespace: namespace)
    }.frame(width: 390, height: 600)
}

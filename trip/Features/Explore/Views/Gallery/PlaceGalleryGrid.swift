import CoreGraphics
import SwiftUI

struct PlaceGalleryGrid: View {
    let controller: PlaceGalleryController
    let namespace: Namespace.ID

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                GalleryGridContent(controller: controller, namespace: namespace)
            }
            .scrollPosition(controller.gridPosition)
            .onScrollTargetVisibilityChange(idType: String.self, threshold: 0.5, controller.observeVisiblePhotos)
            .onScrollGeometryChange(for: GalleryGridViewport.self, of: GalleryGridViewport.init) {
                controller.observeViewport($1)
            }
            .modifier(GalleryGridInteraction(controller: controller, size: geometry.size))
        }
    }
}

#Preview("Zoomable gallery · compact") {
    @Previewable @Namespace var namespace
    PlaceGalleryGrid(controller: PlaceGalleryController(model: PlaceGalleryModel()), namespace: namespace)
        .frame(width: 390, height: 600)
}
#Preview("Zoomable gallery · wide") {
    @Previewable @Namespace var namespace
    PlaceGalleryGrid(controller: PlaceGalleryController(model: PlaceGalleryModel()), namespace: namespace)
        .frame(width: 900, height: 600)
}
#Preview("Zoomable gallery · wide, original proportions") {
    @Previewable @Namespace var namespace
    let model = PlaceGalleryModel()
    model.grid.density = 2
    model.grid.usesAspectRatio = true
    return PlaceGalleryGrid(controller: PlaceGalleryController(model: model), namespace: namespace)
        .frame(width: 900, height: 600)
}

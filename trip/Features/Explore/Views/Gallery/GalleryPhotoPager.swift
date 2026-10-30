import SwiftUI

struct GalleryPhotoPager: View {
    let controller: PlaceGalleryController

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(controller.model.photos) { photo in
                        GalleryPhotoPage(photo: photo, controller: controller)
                            .frame(width: geometry.size.width, height: geometry.size.height).id(photo.id)
                    }
                }.scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: controller.focus)
            .scrollIndicators(.hidden)
            .scrollDisabled(controller.model.isZoomed)
        }
        .ignoresSafeArea()
    }
}

#Preview("Photo pager · starts at selected photo") {
    let model = PlaceGalleryModel()
    model.open(model.photos[3])
    return GalleryPhotoPager(controller: PlaceGalleryController(model: model))
}

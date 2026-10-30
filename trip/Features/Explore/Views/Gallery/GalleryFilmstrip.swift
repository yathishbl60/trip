import SwiftUI

struct GalleryFilmstrip: View {
    let controller: PlaceGalleryController

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(controller.model.photos) { photo in
                        GalleryFilmstripCell(photo: photo, controller: controller).id(photo.id)
                    }
                }.scrollTargetLayout()
            }
            .scrollPosition(id: controller.filmstripPosition, anchor: .center)
            .onScrollPhaseChange { _, phase in controller.scrubPhase(phase) }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, max(0, (geometry.size.width - GalleryFilmstripModel.itemWidth) / 2),
                            for: .scrollContent)
        }
        .frame(height: 60)
    }
}

#Preview("Thumbnail strip · selected") {
    let model = PlaceGalleryModel()
    model.open(model.photos[4])
    return GalleryFilmstrip(controller: PlaceGalleryController(model: model))
}

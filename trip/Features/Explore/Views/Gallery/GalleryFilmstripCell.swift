import SwiftUI
import TripLocalization

struct GalleryFilmstripCell: View {
    let photo: GalleryPhoto
    let controller: PlaceGalleryController
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button { controller.select(photo, reduceMotion: reduceMotion) } label: {
            Image(photo.thumbnailName).resizable().scaledToFill()
                .frame(width: controller.model.focusedID == photo.id ? 42 : 24, height: 36)
                .clipped().clipShape(.rect(cornerRadius: 2))
                .frame(width: GalleryFilmstripModel.itemWidth, height: 60)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(photo.title.resource)
        .accessibilityAddTraits(controller.model.focusedID == photo.id ? .isSelected : [])
    }
}

#Preview("Filmstrip cell · selected") {
    let model = PlaceGalleryModel()
    model.open(model.photos[0])
    return GalleryFilmstripCell(photo: model.photos[0], controller: PlaceGalleryController(model: model))
}

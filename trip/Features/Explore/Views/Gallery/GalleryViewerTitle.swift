import SwiftUI
import TripLocalization

struct GalleryViewerTitle: View {
    let controller: PlaceGalleryController
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 2) {
            if let photo = controller.model.focusedPhoto, !dynamicTypeSize.isAccessibilitySize {
                Text(photo.title.resource).font(.headline).lineLimit(1)
            }
            Text(TripText.gallerySamplePhotos.resource)
                .font(dynamicTypeSize.isAccessibilitySize ? .headline : .caption)
                .foregroundStyle(dynamicTypeSize.isAccessibilitySize ? .primary : .secondary)
        }.accessibilityElement(children: .combine)
    }
}

#Preview("Viewer title · sample label") {
    let model = PlaceGalleryModel()
    model.open(model.photos[0])
    return GalleryViewerTitle(controller: PlaceGalleryController(model: model))
}

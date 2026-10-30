import SwiftUI
import TripLocalization

struct GalleryShareButton: View {
    let controller: PlaceGalleryController

    var body: some View {
        if let photo = controller.model.focusedPhoto {
            ShareLink(item: Image(photo.imageName), preview: SharePreview(TripText.samplePhoto.resource,
                image: Image(photo.thumbnailName))) {
                Label(TripText.gallerySharePhoto.resource, systemImage: "square.and.arrow.up")
            }
            .labelStyle(.iconOnly)
        }
    }
}

#Preview("Share selected sample · native toolbar") {
    let model = PlaceGalleryModel()
    model.open(model.photos[0])
    return NavigationStack {
        Color.clear.toolbar { ToolbarItem { GalleryShareButton(controller: PlaceGalleryController(model: model)) } }
    }
}

import SwiftUI
import TripLocalization

struct GalleryEmptyView: View {
    var body: some View {
        ContentUnavailableView(TripText.galleryNoPhotos.resource, systemImage: "photo.on.rectangle.angled",
                               description: Text(TripText.galleryNoPhotosDescription.resource))
    }
}

#Preview("Gallery · no photos") {
    GalleryEmptyView()
}

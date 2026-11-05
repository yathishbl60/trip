import SwiftUI
import TripDomain
import TripLocalization

struct PlaceDetailPhotoView: View {
    let place: Place
    @State private var gallery = PlaceGalleryModel(photos: [])

    var body: some View {
        if !gallery.photos.isEmpty {
            Button(action: PlaceGalleryController(model: gallery).present) {
                HStack(spacing: AppTheme.Spacing.medium) {
                    GalleryEntryPreview(photos: gallery.photos)
                    Text(TripText.gallerySamplePhotos.resource).foregroundStyle(.primary)
                    Spacer(minLength: AppTheme.Spacing.small)
                    Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
                }
                .padding(.vertical, AppTheme.Spacing.tight).contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(TripText.gallerySamplePhotos.resource)
            .modifier(PlaceGalleryPresentation(placeName: place.name, controller: PlaceGalleryController(model: gallery)))
        }
    }
}

#if DEBUG
#Preview("No bundled photos · details list") {
    NavigationStack { List { PlaceDetailPhotoView(place: PreviewFixtures.hotel) } }
}
#Preview("No bundled photos · dark, accessibility") {
    NavigationStack { List { PlaceDetailPhotoView(place: PreviewFixtures.longName) } }
        .preferredColorScheme(.dark).dynamicTypeSize(.accessibility2)
}
#endif

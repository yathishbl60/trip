import SwiftUI

struct GalleryEntryPreview: View {
    let photos: [GalleryPhoto]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(photos.prefix(3)) { photo in
                Image(photo.thumbnailName).resizable().scaledToFill()
                    .frame(width: 25, height: 52).clipped()
            }
        }
        .clipShape(.rect(cornerRadius: 8))
        .accessibilityHidden(true)
    }
}

#Preview("Gallery entry · sample thumbnails") {
    GalleryEntryPreview(photos: GalleryPhoto.samples)
}

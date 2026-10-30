import SwiftUI
import TripLocalization

struct GalleryTitleView: View {
    let placeName: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 2) {
            Text(TripText.gallerySamplePhotos.resource).font(.headline)
            if !dynamicTypeSize.isAccessibilitySize {
                Text(placeName).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(TripText.gallerySamplePhotos.resource)
        .accessibilityValue(placeName)
    }
}

#Preview("Gallery title · long place name") {
    GalleryTitleView(placeName: "A place with a very long name in Bangkok")
        .frame(width: 240).dynamicTypeSize(.accessibility2)
}

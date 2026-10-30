import CoreGraphics
import SwiftUI
import TripLocalization

struct GalleryGridCell: View {
    let photo: GalleryPhoto
    let controller: PlaceGalleryController
    let namespace: Namespace.ID

    var body: some View {
        Button { controller.open(photo) } label: { image }
        .buttonStyle(.plain)
        .matchedTransitionSource(id: photo.id, in: namespace)
        .accessibilityLabel(photo.title.resource)
        .accessibilityHint(TripText.galleryOpenPhoto.resource)
        .hoverEffect(.highlight)
        .onGeometryChange(for: CGRect?.self) { [isAnchor = controller.model.grid.anchor?.id == photo.id] geometry in
            isAnchor ? geometry.frame(in: .named("galleryGridContent")) : nil
        } action: { frame in
            if let frame { controller.observeFrame(frame, id: photo.id) }
        }
    }

    private var image: some View {
        Image(photo.imageName).resizable().scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity).clipped()
            .contentShape(.rect)
    }
}

#Preview("Photo grid cell") {
    @Previewable @Namespace var namespace
    GalleryGridCell(photo: GalleryPhoto.samples[0],
                    controller: PlaceGalleryController(model: PlaceGalleryModel()), namespace: namespace)
        .frame(width: 140, height: 140)
}

import CoreGraphics
import SwiftUI
import TripLocalization

struct GalleryPhotoAccessibility: ViewModifier {
    let photo: GalleryPhoto
    let zoom: GalleryPhotoZoomModel
    let gallery: PlaceGalleryController
    let size: CGSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(photo.title.resource)
            .accessibilityValue(gallery.model.positionLabel.resource)
            .accessibilityAction { gallery.toggleControls(reduceMotion: reduceMotion) }
            .accessibilityAction(named: TripText.zoomIn.resource, toggleZoom)
            .accessibilityAction(named: TripText.zoomOut.resource) { GalleryPhotoZoomController(model: zoom).reset() }
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: gallery.move(1)
                case .decrement: gallery.move(-1)
                @unknown default: break
                }
            }
    }

    private func toggleZoom() {
        GalleryPhotoZoomController(model: zoom).enlarge(size: size, ratio: photo.aspectRatio, reduceMotion: reduceMotion)
    }
}

#Preview("Accessible photo · large text") {
    let model = PlaceGalleryModel()
    model.open(model.photos[0])
    return GalleryPhotoPage(photo: model.photos[0], controller: PlaceGalleryController(model: model))
        .dynamicTypeSize(.accessibility3)
}

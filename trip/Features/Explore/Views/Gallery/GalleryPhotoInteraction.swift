import CoreGraphics
import SwiftUI

struct GalleryPhotoInteraction: ViewModifier {
    let photo: GalleryPhoto
    let controller: GalleryPhotoZoomController
    let gallery: PlaceGalleryController
    let size: CGSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @GestureState private var isMagnifying = false
    @GestureState private var isPanning = false

    func body(content: Content) -> some View {
        content
            .gesture(taps)
            .simultaneousGesture(magnify)
            .simultaneousGesture(pan, isEnabled: controller.model.scale > 1)
            .onChange(of: isMagnifying) { _, active in
                if !active { controller.finish(size: size, ratio: photo.aspectRatio) }
            }
            .onChange(of: isPanning) { _, active in
                if !active { controller.finishPanning() }
            }
            .onChange(of: size) { old, new in controller.resize(from: old, to: new, ratio: photo.aspectRatio) }
    }

    private var taps: some Gesture {
        SpatialTapGesture(count: 2).exclusively(before: SpatialTapGesture())
            .onEnded { value in
                switch value {
                case .first(let tap):
                    controller.toggle(at: tap.location, size: size, ratio: photo.aspectRatio,
                                      reduceMotion: reduceMotion)
                case .second: gallery.toggleControls(reduceMotion: reduceMotion)
                }
            }
    }

    private var magnify: some Gesture {
        MagnifyGesture()
            .updating($isMagnifying) { _, active, _ in active = true }
            .onChanged {
                controller.magnify($0, size: size, ratio: photo.aspectRatio)
            }
            .onEnded { _ in controller.finish(size: size, ratio: photo.aspectRatio) }
    }

    private var pan: some Gesture {
        DragGesture(minimumDistance: 4)
            .updating($isPanning) { _, active, _ in active = true }
            .onChanged { controller.pan($0.translation, size: size, ratio: photo.aspectRatio) }
            .onEnded {
                controller.settlePan($0.predictedEndTranslation, size: size,
                                     ratio: photo.aspectRatio, reduceMotion: reduceMotion)
            }
    }
}

#Preview("Photo gestures · local image") {
    let model = PlaceGalleryModel()
    model.open(model.photos[0])
    return GalleryPhotoPage(photo: model.photos[0], controller: PlaceGalleryController(model: model))
}

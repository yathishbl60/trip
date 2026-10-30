import SwiftUI
import TripLocalization

struct GalleryViewerToolbar: ToolbarContent {
    let controller: PlaceGalleryController

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            GalleryViewerTitle(controller: controller)
        }.horizontalToolbarItem()
        ToolbarItem(placement: .primaryAction) {
            Button(TripText.galleryAboutSamples.resource, systemImage: "info.circle", action: controller.showInformation)
        }
        #if os(iOS)
        ToolbarItem(placement: .bottomBar) { GalleryShareButton(controller: controller) }
            .prioritizedToolbarItem()
        ToolbarItem(placement: .bottomBar) {
            Text(controller.model.positionLabel.resource).font(.caption).foregroundStyle(.secondary)
        }.horizontalToolbarItem()
        #else
        ToolbarItem(placement: .secondaryAction) { GalleryShareButton(controller: controller) }
        #endif
    }
}

#Preview("Viewer toolbar") {
    let model = PlaceGalleryModel()
    model.open(model.photos[0])
    return NavigationStack { GalleryViewerView(placeName: "Bangkok", controller: PlaceGalleryController(model: model)) }
}

#Preview("Viewer toolbar · short window, large text") {
    let model = PlaceGalleryModel()
    model.open(model.photos[0])
    return NavigationStack { GalleryViewerView(placeName: "Bangkok", controller: PlaceGalleryController(model: model)) }
        .frame(width: 680, height: 320).dynamicTypeSize(.accessibility1)
}

import SwiftUI
import TripLocalization

struct PlaceGalleryView: View {
    let placeName: String
    let controller: PlaceGalleryController
    @Namespace private var namespace
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            PlaceGalleryGrid(controller: controller, namespace: namespace)
                .navigationTitle(TripText.gallerySamplePhotos.resource)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button(role: .close) { dismiss() } }
                    ToolbarItem(placement: .principal) { GalleryTitleView(placeName: placeName) }
                }
                .overlay { if controller.model.photos.isEmpty { GalleryEmptyView() } }
                .modifier(GalleryViewerPresentation(placeName: placeName, controller: controller, namespace: namespace))
        }
        .sheet(isPresented: controller.gridInformation) { GalleryInformationView() }
    }
}

#Preview("Place gallery · offline samples") {
    PlaceGalleryView(placeName: "Bangkok", controller: PlaceGalleryController(model: PlaceGalleryModel()))
}
#Preview("Place gallery · dark and large text") {
    PlaceGalleryView(placeName: "A place with a very long name",
                     controller: PlaceGalleryController(model: PlaceGalleryModel()))
        .preferredColorScheme(.dark).dynamicTypeSize(.accessibility2)
}
#Preview("Place gallery · empty") {
    PlaceGalleryView(placeName: "Bangkok", controller: PlaceGalleryController(model: PlaceGalleryModel(photos: [])))
}

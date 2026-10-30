import SwiftUI

struct PlaceGalleryPresentation: ViewModifier {
    let placeName: String
    let controller: PlaceGalleryController

    func body(content: Content) -> some View {
        content
            #if os(iOS)
            .fullScreenCover(isPresented: controller.presentation) {
                PlaceGalleryView(placeName: placeName, controller: controller)
            }
            #else
            .sheet(isPresented: controller.presentation) {
                PlaceGalleryView(placeName: placeName, controller: controller).frame(minWidth: 600, minHeight: 500)
            }
            #endif
    }
}

#Preview("Place gallery · presentation") {
    let model = PlaceGalleryModel()
    let controller = PlaceGalleryController(model: model)
    Button("Open gallery", action: controller.present)
        .modifier(PlaceGalleryPresentation(placeName: "Bangkok", controller: controller))
}

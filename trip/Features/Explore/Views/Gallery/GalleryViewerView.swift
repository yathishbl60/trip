import SwiftUI
import TripLocalization

struct GalleryViewerView: View {
    let placeName: String
    let controller: PlaceGalleryController

    var body: some View {
        GalleryPhotoPager(controller: controller)
            .background(controller.model.hidesControls ? AnyShapeStyle(.black) : AnyShapeStyle(.background))
            .overlay(alignment: .bottom) { GalleryViewerFooter(controller: controller) }
            .toolbar { GalleryViewerToolbar(controller: controller) }
            .toolbarVisibility(controller.model.hidesControls ? .hidden : .visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            #if os(iOS)
            .toolbarVisibility(controller.model.hidesControls ? .hidden : .visible, for: .bottomBar, .statusBar)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .sheet(isPresented: controller.information) { GalleryInformationView() }
            .accessibilityAction(.escape, controller.closeViewer)
    }
}

#Preview("Full-screen viewer · selected photo") {
    let model = PlaceGalleryModel()
    model.open(model.photos[3])
    return NavigationStack { GalleryViewerView(placeName: "Bangkok", controller: PlaceGalleryController(model: model)) }
}
#Preview("Full-screen viewer · immersive") {
    let model = PlaceGalleryModel()
    model.open(model.photos[11])
    model.toggleControls()
    return NavigationStack { GalleryViewerView(placeName: "Bangkok", controller: PlaceGalleryController(model: model)) }
}

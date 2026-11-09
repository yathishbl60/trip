import SwiftUI
import TripDomain

/// Transient overlays leave the Maps logo and Legal at the container's safe area.
struct MapCanvasView: View {
    let controller: MapController
    @Environment(\.dismissSearch) private var dismissSearch

    var body: some View {
        GeometryReader { _ in
            ExploreMapView(controller: controller)
                .overlay(alignment: .bottom) { searchStatus }
        }
        .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .global) },
                          action: controller.visibleAreaChanged)
        .onChange(of: controller.model.catalog.isSearchPresented) { _, presented in
            if !presented { dismissSearch() }
        }
    }

    private var searchStatus: some View {
        MapSearchStatusView(model: controller.model.catalog,
                            showsProgress: controller.model.mapSheet == nil && !controller.model.catalog.isSearchPresented
                                && !controller.model.savedMap.isActive,
                            motion: controller.model.configuration.motion,
                            retry: CatalogController(model: controller.model).search,
                            areaChanged: controller.noticeAreaChanged)
            .padding(.bottom, 32)
    }
}

#if DEBUG
#Preview("Native map chrome · search progress") {
    MapCanvasView(controller: MapController(model: PreviewFixtures.searching()))
}
#Preview("Stable attribution · toggle loading") {
    @Previewable @State var model = PreviewFixtures.searching()
    MapCanvasView(controller: MapController(model: model))
        .overlay(alignment: .top) {
            Button("Toggle loading") {
                model.catalog.status = ""
                model.catalog.isSearching.toggle()
            }.buttonStyle(.bordered).padding()
        }
}
#Preview("Native map chrome · landscape", traits: .landscapeLeft) {
    MapCanvasView(controller: MapController(model: PreviewFixtures.explore()))
}
#Preview("Native map chrome · large text, dark") {
    MapCanvasView(controller: MapController(model: PreviewFixtures.offline()))
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("No matching places · local search result") {
    MapCanvasView(controller: MapController(model: PreviewFixtures.noMatches()))
}
#Preview("Filtered map · unobstructed, local places, system map tiles") {
    MapCanvasView(controller: MapController(model: PreviewFixtures.explore(categories: [.hotel, .cafe])))
}
#Preview("Filtered map · compact, large text") {
    MapCanvasView(controller: MapController(model: PreviewFixtures.explore(categories: [.entertainment])))
        .frame(width: 320, height: 600).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

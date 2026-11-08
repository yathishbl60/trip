import SwiftUI
import TripDomain

struct MapToolPresentation<Panel: View>: ViewModifier {
    let controller: PlaceController
    @ViewBuilder let panel: (ExploreSheet) -> Panel
    #if os(visionOS)
    @State private var visibility = NavigationSplitViewVisibility.all
    #endif

    func body(content: Content) -> some View {
        #if os(visionOS)
        spatialMap(content, destination: controller.model.mapSheet)
        #else
        content.sheet(item: controller.mapSheet) { destination in
            panel(destination)
                .frame(idealWidth: 400)
                .presentationSizing(.automatic.fitted(horizontal: true, vertical: false))
        }
        #endif
    }

    #if os(visionOS)
    private func spatialMap(_ content: Content, destination: ExploreSheet?) -> some View {
        NavigationSplitView(columnVisibility: destination == nil ? .constant(.detailOnly) : $visibility) {
            if let destination {
                panel(destination)
                    .navigationSplitViewColumnWidth(min: 300, ideal: 360, max: 450)
            }
        } detail: {
            content.toolbar(removing: destination == nil ? .sidebarToggle : nil)
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: destination) { visibility = .all }
        .onChange(of: controller.model.selection.rootPlace?.id) { visibility = .all }
    }
    #endif
}

#if DEBUG
#Preview("Explore · place beside the map, live map tiles") {
    let model = PreviewFixtures.hotels()
    model.select(PreviewFixtures.hotel)
    return MapExperienceView(model: model) { place, controller in
        PlaceDetailView(place: place, controller: controller)
    }.frame(width: 1100, height: 720)
}
#endif

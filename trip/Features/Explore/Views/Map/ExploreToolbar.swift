import TripLocalization
import SwiftUI

struct ExploreToolbar: ToolbarContent {
    let controller: MapController

    var body: some ToolbarContent {
        ToolbarItem(id: "map.previous-area", placement: .topBarLeading) {
            if controller.model.showsMapControls && controller.model.camera.canGoBack {
                Button(TripText.previousArea.resource, systemImage: "arrow.uturn.backward") {
                    MapNavigationController(model: controller.model).goBack()
                }
            }
        }.prioritizedToolbarItem()
        ToolbarItem(id: "map.options", placement: .topBarLeading) {
            if controller.model.showsMapControls {
                MapMenuOptions(controller: FilterController(model: controller.model))
            } else if !controller.model.catalog.isSearchPresented && !controller.model.environment.isSavingPlace() {
                MapStyleMenu(model: controller.model.appearance)
            }
        }
    }
}

#if DEBUG
#Preview("Map toolbar") {
    NavigationStack {
        Color.clear.toolbar { ExploreToolbar(controller: MapController(model: PreviewFixtures.explore())) }
    }
}
#Preview("Map toolbar · dark") {
    NavigationStack {
        Color.clear.toolbar { ExploreToolbar(controller: MapController(model: PreviewFixtures.focused())) }
    }.preferredColorScheme(.dark)
}
#Preview("Searching · clear navigation header") {
    let model = PreviewFixtures.searching()
    model.catalog.isSearchPresented = true
    return NavigationStack {
        Color.clear.toolbar { ExploreToolbar(controller: MapController(model: model)) }
    }
    .searchable(text: CatalogController(model: model).query,
                isPresented: CatalogController(model: model).searchPresentation)
    .searchToolbarBehavior(.minimize)
}
#Preview("3D · contextual return") {
    let model = PreviewFixtures.explore()
    model.camera.exploreIn3D()
    return NavigationStack {
        Color.clear.toolbar { ExploreToolbar(controller: MapController(model: model)) }
    }
}
#endif

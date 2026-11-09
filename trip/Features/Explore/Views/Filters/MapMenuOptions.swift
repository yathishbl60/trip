import TripLocalization
import MapEngine
import SwiftUI

struct MapMenuOptions: View {
    let controller: FilterController

    var body: some View {
        Menu {
            discovery
            searchActions
            MapStyleOptions(controller: MapAppearanceController(model: controller.model.appearance))
            Section(TripText.perspective.resource) {
                MapNavigationOptions(controller: MapNavigationController(model: controller.model))
                Picker(TripText.mapScale.resource, selection: controller.zoomSelection) {
                    ForEach(ZoomLevel.allCases, id: \.self) { Text($0.title).tag($0) }
                }.pickerStyle(.menu)
            }
        } label: {
            Label(TripText.mapOptions.resource, systemImage: "map")
        }
        .badge(controller.model.showsCategoryControls ? controller.model.filters.selected.count : 0)
        .accessibilityValue(controller.model.filters.summary)
    }

    private var discovery: some View {
        Section {
            SavedMapPicker(controller: SavedMapController(model: controller.model))
            Button(TripText.browseThisArea.resource, systemImage: "list.bullet") {
                MapBrowseController(model: controller.model).open()
            }
            if controller.model.showsCategoryControls {
                Button(controller.model.filters.summary, systemImage: controller.model.filters.symbol,
                       action: controller.show)
            }
        }
    }

    private var searchActions: some View {
        Section {
            if !controller.model.catalog.query.isEmpty {
                Button(TripText.clearSearch.resource, systemImage: "xmark.circle") {
                    CatalogController(model: controller.model).clearSearch()
                }
            }
            if !controller.model.catalog.isSearching {
                Button(TripText.searchThisArea.resource, systemImage: "arrow.clockwise") {
                    CatalogController(model: controller.model).search()
                }
            }
        }
    }
}

#if DEBUG
#Preview("Map options", traits: .sizeThatFitsLayout) {
    MapMenuOptions(controller: FilterController(model: PreviewFixtures.explore())).padding()
}
#Preview("Map options · dark", traits: .sizeThatFitsLayout) {
    MapMenuOptions(controller: FilterController(model: PreviewFixtures.focused()))
        .padding().preferredColorScheme(.dark)
}
#endif

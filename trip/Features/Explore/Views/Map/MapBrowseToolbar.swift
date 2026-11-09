import SwiftUI
import TripDomain
import TripLocalization

struct MapBrowseToolbar: ToolbarContent {
    let controller: MapBrowseController

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .close, action: controller.close)
        }
        ToolbarItem(placement: .topBarTrailing) {
            if controller.model.showsCategoryControls { filters }
        }
    }

    private var filters: some View {
        Menu(TripText.choosePlaceCategories.resource, systemImage: "line.3.horizontal.decrease") {
            Button(TripText.allCategories.resource) { FilterController(model: controller.model).clear() }
            ForEach(controller.model.filters.rows) { row in
                Button(row.category.title, systemImage: row.isSelected ? "checkmark" : row.category.symbol) {
                    FilterController(model: controller.model).toggle(row.category)
                }
            }
        }.accessibilityValue(controller.model.filters.summary)
    }
}

#if DEBUG
#Preview("Results filters · local") {
    NavigationStack { Color.clear.toolbar { MapBrowseToolbar(controller: MapBrowseController(model: PreviewFixtures.explore())) } }
}
#endif

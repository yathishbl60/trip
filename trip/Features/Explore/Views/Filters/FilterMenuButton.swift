import TripLocalization
import TripDomain
import SwiftUI

struct FilterMenuButton: View {
    let controller: FilterController

    var body: some View {
        Button(TripText.filters.resource, systemImage: controller.model.filters.symbol, action: controller.show)
            .tripSymbolReplacement(value: controller.model.filters.allSelected)
            .badge(controller.model.filters.selected.count)
            .accessibilityHint(TripText.choosePlaceCategories.resource)
            .sheet(isPresented: controller.presentation) {
                FilterPanelView(controller: controller)
            }
    }
}

#if DEBUG
#Preview("Filters in toolbar") {
    NavigationStack {
        Color.clear.toolbar {
            FilterMenuButton(controller: FilterController(model: PreviewFixtures.explore()))
        }
    }
}
#Preview("Active filters · dark") {
    NavigationStack {
        Color.clear.toolbar {
            FilterMenuButton(controller: FilterController(model: PreviewFixtures.explore(categories: [.hotel])))
        }
    }.preferredColorScheme(.dark)
}
#endif

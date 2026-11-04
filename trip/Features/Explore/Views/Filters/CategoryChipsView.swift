import TripLocalization
import TripDomain
import SwiftUI

struct CategoryChipsView: View {
    let controller: FilterController
    @Namespace private var namespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .subheadline) private var columnWidth: CGFloat = 145

    var body: some View {
        container
            .animation(reduceMotion ? nil : .smooth(duration: 0.25), value: controller.model.filters.selected)
    }

    @ViewBuilder private var container: some View {
        #if os(visionOS)
        controls
        #else
        GlassEffectContainer(spacing: 12) { controls }
        #endif
    }

    private var controls: some View {
        VStack(spacing: 12) {
            CategoryFilterChip(title: TripText.allCategories.text,
                               symbol: controller.model.filters.allSelected ? "checkmark" : "square.grid.2x2",
                               id: "all", namespace: namespace,
                               isSelected: controller.model.filters.allSelected, action: controller.clear)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: columnWidth), spacing: 12)], spacing: 12) {
                ForEach(controller.model.filters.rows) { row in chip(row) }
            }
        }
    }

    private func chip(_ row: CategoryRow) -> some View {
        CategoryFilterChip(title: row.category.title, symbol: row.isSelected ? "checkmark" : row.category.symbol,
                           id: row.category.rawValue, namespace: namespace,
                           isSelected: row.isSelected, count: row.count) {
            controller.toggle(row.category)
        }
        .accessibilityValue(TripText.loadedPlaceCount(row.count).resource)
    }
}

#if DEBUG
#Preview("Animated categories · interactive, local") {
    CategoryChipsView(controller: FilterController(model: PreviewFixtures.explore(categories: [.hotel])))
        .padding().frame(width: 390)
}
#Preview("Category choices · dark, local") {
    CategoryChipsView(controller: FilterController(model: PreviewFixtures.explore(categories: [.hotel, .cafe])))
        .padding().frame(width: 390).preferredColorScheme(.dark)
}
#Preview("Category choices · compact, large text") {
    CategoryChipsView(controller: FilterController(model: PreviewFixtures.explore()))
        .padding().frame(width: 320).dynamicTypeSize(.xxxLarge)
}
#endif

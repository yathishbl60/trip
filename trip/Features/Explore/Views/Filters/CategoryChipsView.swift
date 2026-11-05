import TripLocalization
import TripDomain
import SwiftUI

struct CategoryChipsView: View {
    let controller: FilterController
    @Namespace private var namespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .subheadline) private var columnWidth: CGFloat = 145

    var body: some View {
        container
            .animation(AppTheme.Motion.selection(reduceMotion: reduceMotion), value: controller.model.filters.selected)
    }

    @ViewBuilder private var container: some View {
        #if os(visionOS)
        controls
        #else
        GlassEffectContainer(spacing: AppTheme.Spacing.medium) { controls }
        #endif
    }

    private var controls: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            CategoryFilterChip(title: TripText.allCategories.text,
                               symbol: controller.model.filters.allSelected ? "checkmark" : "square.grid.2x2",
                               id: "all", namespace: namespace,
                               isSelected: controller.model.filters.allSelected, action: controller.clear)
            LazyVGrid(columns: columns, spacing: AppTheme.Spacing.medium) {
                ForEach(controller.model.filters.rows) { row in chip(row) }
            }
        }
    }

    private var columns: [GridItem] {
        [GridItem(typeSize.isAccessibilitySize ? .flexible() : .adaptive(minimum: columnWidth),
                  spacing: AppTheme.Spacing.medium)]
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
#Preview("Category choices · narrow, accessibility") {
    CategoryChipsView(controller: FilterController(model: PreviewFixtures.explore()))
        .padding().frame(width: 320).dynamicTypeSize(.accessibility5).preferredColorScheme(.dark)
}
#endif

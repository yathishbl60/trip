import TripLocalization
import TripDomain
import SwiftUI

struct CategoryChipsView: View {
    let controller: FilterController

    var body: some View {
        ScrollView(.horizontal) {
            container
        }
        .scrollIndicators(.hidden)
        .sensoryFeedback(.selection, trigger: controller.model.filters.selected)
    }

    @ViewBuilder private var container: some View {
        #if os(visionOS)
        chips
        #else
        GlassEffectContainer(spacing: 10) { chips }
        #endif
    }

    private var chips: some View {
        HStack(spacing: 10) {
            Button(TripText.all.resource, systemImage: "square.grid.2x2", action: controller.clear)
                .buttonStyle(TripButtonStyles.regular)
            ForEach(controller.model.filters.rows) { row in chip(row) }
        }
        .padding(.horizontal, AppTheme.spacing).padding(.vertical, 6)
    }

    private func chip(_ row: CategoryRow) -> some View {
        Button(row.category.title, systemImage: row.isSelected ? "checkmark" : row.category.symbol) {
            controller.toggle(row.category)
        }
        .tripSymbolReplacement(value: row.isSelected)
        .buttonStyle(TripButtonStyles.regular)
        .tint(row.isSelected ? AppTheme.accent : .primary)
        .accessibilityAddTraits(row.isSelected ? .isSelected : [])
    }
}

#if DEBUG
#Preview("Category rail", traits: .sizeThatFitsLayout) {
    CategoryChipsView(controller: FilterController(model: PreviewFixtures.explore()))
}
#Preview("Selected category · dark", traits: .sizeThatFitsLayout) {
    CategoryChipsView(controller: FilterController(model: PreviewFixtures.explore(categories: [.hotel])))
        .preferredColorScheme(.dark)
}
#endif

import TripLocalization
import TripDomain
import SwiftUI

struct CategoryFilterRow: View {
    let row: CategoryRow
    let controller: FilterController

    var body: some View {
        Button { controller.toggle(row.category) } label: { label }
        .buttonStyle(.plain)
        .hoverEffect(.highlight)
        .accessibilityLabel(row.category.title)
        .accessibilityValue(TripText.loadedPlaceCount(row.count).resource)
        .accessibilityAddTraits(row.isSelected ? .isSelected : [])
    }

    private var label: some View { CategoryFilterLabel(row: row) }
}

#if DEBUG
#Preview("Selected and unselected", traits: .sizeThatFitsLayout) {
    VStack {
        CategoryFilterRow(row: CategoryRow(category: .restaurant, count: 109, isSelected: true),
                          controller: FilterController(model: PreviewFixtures.explore()))
        CategoryFilterRow(row: CategoryRow(category: .hotel, count: 56, isSelected: false),
                          controller: FilterController(model: PreviewFixtures.explore()))
        CategoryFilterRow(row: CategoryRow(category: .museum, count: 0, isSelected: false),
                          controller: FilterController(model: PreviewFixtures.explore()))
    }
    .frame(width: 310).padding()
}
#Preview("Long category · accessibility", traits: .sizeThatFitsLayout) {
    CategoryFilterRow(row: CategoryRow(category: .entertainment, count: 6, isSelected: true),
                      controller: FilterController(model: PreviewFixtures.explore()))
        .frame(width: 310).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

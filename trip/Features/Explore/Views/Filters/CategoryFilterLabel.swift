import TripLocalization
import SwiftUI
import TripDomain

struct CategoryFilterLabel: View {
    let row: CategoryRow
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            CategoryBadge(category: row.category, diameter: 36)
            VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
                Text(row.category.title).font(.body).fixedSize(horizontal: false, vertical: true)
                if typeSize.isAccessibilitySize {
                    Text(TripText.placesValue(TripText.number(row.count)).resource).font(.caption).foregroundStyle(.secondary).accessibilityHidden(true)
                }
            }.frame(maxWidth: .infinity, alignment: .leading).layoutPriority(1)
            if !typeSize.isAccessibilitySize { countBadge }
            Image(systemName: row.checkmark)
                .tripSymbolReplacement(value: row.isSelected)
                .foregroundStyle(row.isSelected ? AppTheme.accent : .secondary).fixedSize()
        }
        .padding(.vertical, AppTheme.Spacing.tight)
        .frame(minHeight: AppTheme.controlTarget).contentShape(.rect)
    }

    private var countBadge: some View {
        Text(row.count, format: .number).font(.subheadline.monospacedDigit())
            .contentTransition(.numericText())
            .padding(.horizontal, AppTheme.Spacing.small).background(.quaternary, in: .capsule)
            .accessibilityHidden(true).fixedSize()
    }
}

#Preview("Filter label · long category") {
    CategoryFilterLabel(row: CategoryRow(category: .entertainment, count: 1200, isSelected: true))
        .padding().frame(width: 280)
}
#Preview("Filter label · accessibility") {
    List { CategoryFilterLabel(row: CategoryRow(category: .entertainment, count: 1200, isSelected: true)) }
        .frame(width: 320).dynamicTypeSize(.accessibility3).preferredColorScheme(.dark)
}

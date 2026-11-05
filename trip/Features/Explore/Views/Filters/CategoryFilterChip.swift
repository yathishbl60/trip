import SwiftUI

struct CategoryFilterChip: View {
    let title: String
    let symbol: String
    let id: String
    let namespace: Namespace.ID
    var isSelected = false
    var count: Int? = nil
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        #if os(visionOS)
        button.buttonStyle(.bordered)
        #else
        button.buttonStyle(.plain)
            .glassEffect(.regular.interactive())
            .glassEffectID(id, in: namespace)
            .glassEffectTransition(reduceMotion ? .identity : .matchedGeometry)
        #endif
    }

    private var button: some View {
        Button(action: action) { label }
            .accessibilityLabel(title)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var label: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: AppTheme.Spacing.tight))
            : AnyLayout(HStackLayout(spacing: AppTheme.Spacing.small))
        return layout {
            identity
            if let count {
                Text(count, format: .number).font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                    .contentTransition(reduceMotion ? .identity : .numericText()).fixedSize().accessibilityHidden(true)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.medium)
        .padding(.vertical, AppTheme.Spacing.small)
        .frame(maxWidth: .infinity, minHeight: AppTheme.controlTarget)
        .foregroundStyle(isSelected ? AppTheme.accent : .primary)
    }

    private var identity: some View {
        Label { Text(title) } icon: {
            Image(systemName: symbol).tripSymbolReplacement(value: symbol)
        }
        .font(.subheadline.weight(.medium))
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview("Filter chip · selected") {
    @Previewable @Namespace var namespace
    CategoryFilterChip(title: "Cafés", symbol: "checkmark", id: "cafe", namespace: namespace,
                       isSelected: true, count: 12, action: {}).padding().frame(width: 200)
}
#Preview("Filter chip · large text, dark") {
    @Previewable @Namespace var namespace
    CategoryFilterChip(title: "Entertainment", symbol: "theatermasks", id: "entertainment",
                       namespace: namespace, count: 1200, action: {})
        .padding().frame(width: 200).dynamicTypeSize(.xxxLarge).preferredColorScheme(.dark)
}

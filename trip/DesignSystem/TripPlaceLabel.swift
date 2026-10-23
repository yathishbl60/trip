import SwiftUI

struct TripPlaceLabel: View {
    let title: String
    let subtitle: String
    let symbol: String
    let color: Color
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            TripSymbolTile(symbol: symbol, color: color)
            VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
                Text(title).font(.headline).foregroundStyle(.primary)
                    .lineLimit(typeSize.isAccessibilitySize ? nil : 2)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
                    .lineLimit(typeSize.isAccessibilitySize ? nil : 2)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: AppTheme.controlTarget)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Place identity · list") {
    List {
        TripPlaceLabel(title: "Riverside Hotel", subtitle: "Hotel", symbol: "bed.double.fill", color: .purple)
        TripPlaceLabel(title: "Weekend market", subtitle: "Shopping", symbol: "bag.fill", color: .pink)
    }
}
#Preview("Place identity · accessibility") {
    TripPlaceLabel(title: "A long place name by the riverside", subtitle: "Bangkok, Thailand",
                  symbol: "mappin", color: AppTheme.accent)
        .padding().frame(width: 320).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Place row · tap anywhere in the label") {
    @Previewable @State var isSelected = false
    List {
        Button { isSelected.toggle() } label: {
            TripPlaceLabel(title: "Riverside Hotel", subtitle: "Bangkok", symbol: "bed.double.fill", color: .purple)
        }.buttonStyle(.plain)
        Text(isSelected ? "Selected" : "Tap the name or empty space in the row")
    }
}

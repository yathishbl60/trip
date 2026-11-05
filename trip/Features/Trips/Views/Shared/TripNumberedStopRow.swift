import TripLocalization
import SwiftUI
import TripDomain

struct TripNumberedStopRow: View {
    let place: Place
    let number: Int
    var isSelected = false
    var showsNumber = true
    @ScaledMetric(relativeTo: .subheadline) private var badgeSize = 32.0

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
            if showsNumber { numberBadge }
            description
            if isSelected { Image(systemName: "checkmark").foregroundStyle(AppTheme.accent) }
        }
        .frame(minHeight: AppTheme.controlTarget)
        .padding(.vertical, AppTheme.Spacing.tight)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(TripText.stopValueValueValue(TripText.number(number), place.name, place.category.annotationTitle).resource)
    }

    private var numberBadge: some View {
        Text(number, format: .number).font(.subheadline.monospacedDigit().weight(.semibold))
            .foregroundStyle(isSelected ? AppTheme.onAccentFill : AppTheme.accent)
            .frame(minWidth: badgeSize, minHeight: badgeSize)
            .background(isSelected ? AppTheme.accentFill : AppTheme.accent.opacity(0.12), in: .circle)
    }

    private var description: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
            Text(place.name).font(.headline).foregroundStyle(.primary)
            Label(place.category.annotationTitle, systemImage: place.category.symbol)
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
#Preview("Numbered stop", traits: .sizeThatFitsLayout) {
    TripNumberedStopRow(place: PreviewFixtures.hotel, number: 1).padding()
}
#Preview("Selected stop · large text", traits: .sizeThatFitsLayout) {
    TripNumberedStopRow(place: PreviewFixtures.longName, number: 100, isSelected: true)
        .padding().dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

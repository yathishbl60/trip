import SwiftUI

/// Move the sequence badge above content when large text needs the full row width.
struct TripItineraryRowLayout: ViewModifier {
    let number: Int
    let color: Color
    let continuesSequence: Bool
    let isComplete: Bool
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .subheadline) private var railWidth = 32.0

    @ViewBuilder func body(content: Content) -> some View {
        if typeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                rail.fixedSize(horizontal: false, vertical: true)
                content
            }
        } else {
            content
                .padding(.leading, railWidth + AppTheme.Spacing.medium)
                .overlay(alignment: .leading) { rail }
        }
    }

    private var rail: some View {
        TripItineraryRail(number: number, color: color,
                          continuesSequence: continuesSequence && !typeSize.isAccessibilitySize, isComplete: isComplete)
    }
}

#if DEBUG
#Preview("Itinerary layout · accessible editing width") {
    Text("Bangkok Boutique Hotel").font(.headline)
        .modifier(TripItineraryRowLayout(number: 1, color: AppTheme.accent, continuesSequence: false, isComplete: false))
        .frame(width: 220, alignment: .leading).padding().dynamicTypeSize(.accessibility3)
}
#endif

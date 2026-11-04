import SwiftUI

/// Drawn in the row's overlay so the connector never changes its content height.
struct TripItineraryRail: View {
    let number: Int
    let color: Color
    let continuesSequence: Bool
    var symbol: String? = nil
    var isComplete = false
    @ScaledMetric(relativeTo: .subheadline) private var badgeSize = 32.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            badge
                .font(.subheadline.monospacedDigit().weight(.semibold))
                .foregroundStyle(color)
                .frame(minWidth: badgeSize, minHeight: badgeSize)
                .background(color.opacity(0.12), in: .circle)
            if continuesSequence { Rectangle().fill(.quaternary).frame(width: 2) }
            else { Spacer(minLength: 0) }
        }
        .frame(width: badgeSize)
        .animation(reduceMotion ? nil : .smooth(duration: 0.25), value: isComplete)
        .accessibilityHidden(true).allowsHitTesting(false)
    }

    @ViewBuilder private var badge: some View {
        if let symbol { Image(systemName: symbol) }
        else {
            ZStack {
                Text(number, format: .number).opacity(isComplete ? 0 : 1)
                TripCompletionSymbol(isComplete: isComplete).opacity(isComplete ? 1 : 0)
            }
        }
    }
}

#if DEBUG
#Preview("Itinerary sequence", traits: .sizeThatFitsLayout) {
    HStack(spacing: 30) {
        TripItineraryRail(number: 1, color: AppTheme.accent, continuesSequence: true)
        TripItineraryRail(number: 2, color: .orange, continuesSequence: false)
    }.frame(height: 100).padding()
}
#Preview("Itinerary sequence · large text", traits: .sizeThatFitsLayout) {
    TripItineraryRail(number: 100, color: AppTheme.accent, continuesSequence: true)
        .frame(height: 160).padding().dynamicTypeSize(.accessibility2)
}
#Preview("Visit completion and undo · interactive") {
    @Previewable @State var complete = false
    VStack {
        TripItineraryRail(number: 2, color: AppTheme.accent, continuesSequence: true, isComplete: complete)
            .frame(height: 100)
        Button("Toggle visit") { complete.toggle() }
    }.padding()
}
#endif

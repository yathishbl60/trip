import SwiftUI
import TripDomain

struct TripScheduleSummaryView: View {
    let timeline: TripDayTimeline
    var showsTarget = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Label(timeline.summaryText, systemImage: "clock")
                .font(.subheadline.weight(.semibold)).foregroundStyle(.primary)
            if showsTarget { Text(timeline.targetText).font(.footnote).foregroundStyle(.secondary) }
            if showsTarget { TripTimeBudgetView(timeline: timeline) }
            ForEach(timeline.warnings, id: \.self) { warning in
                TripWarningLabel(message: warning).font(.footnote)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Day schedule", traits: .sizeThatFitsLayout) {
    let trip = TripSchedulePreview.plan()
    if let timeline = TripDayTimeline(day: trip.days[0], date: trip.startDate) {
        TripScheduleSummaryView(timeline: timeline).padding()
    }
}
#Preview("Overloaded day · large text", traits: .sizeThatFitsLayout) {
    let trip = TripSchedulePreview.plan(overloaded: true)
    if let timeline = TripDayTimeline(day: trip.days[0], date: trip.startDate) {
        TripScheduleSummaryView(timeline: timeline).padding().frame(width: 300)
            .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
    }
}
#Preview("Overnight schedule", traits: .sizeThatFitsLayout) {
    let trip = TripSchedulePreview.plan(overnight: true)
    if let timeline = TripDayTimeline(day: trip.days[0], date: trip.startDate) {
        TripScheduleSummaryView(timeline: timeline).padding()
    }
}
#endif

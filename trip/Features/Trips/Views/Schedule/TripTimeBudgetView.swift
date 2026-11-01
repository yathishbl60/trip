import TripLocalization
import Charts
import SwiftUI
import TripDomain

struct TripTimeBudgetView: View {
    let budget: TripTimeBudget
    private let segments: [TripTimeAllocation]
    @Environment(\.dynamicTypeSize) private var typeSize

    init(timeline: TripDayTimeline) {
        budget = TripTimeBudget(timeline: timeline)
        segments = TripTimeAllocation.segments(budget)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            chart
            LazyVGrid(columns: [GridItem(typeSize.isAccessibilitySize ? .flexible() : .adaptive(minimum: 120), alignment: .leading)],
                      alignment: .leading, spacing: AppTheme.Spacing.small) {
                ForEach(segments) { segment in legend(segment) }
            }
            if budget.travel > 0 {
                Text(TripText.travelUsesYourAllowances.resource).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var chart: some View {
        Chart(segments) { segment in
            BarMark(xStart: .value(TripText.start.text, segment.start), xEnd: .value(TripText.end.text, segment.end), y: .value(TripText.time.text, TripText.day.text))
                .foregroundStyle(segment.color)
                .accessibilityLabel(segment.title).accessibilityValue(TripScheduleText.duration(segment.minutes))
            if budget.overrun > 0, segment.kind == .visits {
                RuleMark(x: .value(TripText.target.text, budget.target))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [3]))
                    .foregroundStyle(.primary)
                    .accessibilityLabel(TripText.targetDuration.resource).accessibilityValue(TripScheduleText.duration(budget.target))
            }
        }
        .chartXScale(domain: 0...max(budget.total, 1)).chartXAxis(.hidden).chartYAxis(.hidden)
        .frame(height: 24).accessibilityLabel(TripText.plannedTimeBreakdown.resource)
    }

    private func legend(_ segment: TripTimeAllocation) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.tight) {
            Image(systemName: segment.symbol).foregroundStyle(segment.kind == .open ? .secondary : segment.color)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(segment.title).foregroundStyle(.secondary)
                Text(TripScheduleText.duration(segment.minutes)).monospacedDigit()
            }
        }
        .font(.caption).fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Day time budget", traits: .sizeThatFitsLayout) {
    let trip = TripSchedulePreview.plan()
    if let timeline = TripDayTimeline(day: trip.days[0], date: trip.startDate) {
        TripTimeBudgetView(timeline: timeline).padding()
    }
}
#Preview("Time budget · over target, large text", traits: .sizeThatFitsLayout) {
    let trip = TripSchedulePreview.plan(overloaded: true)
    if let timeline = TripDayTimeline(day: trip.days[0], date: trip.startDate) {
        TripTimeBudgetView(timeline: timeline).padding().frame(width: 320)
            .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
    }
}
#endif

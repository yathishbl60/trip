import SwiftUI
import TripDomain

struct TripStopTimeView: View {
    let timing: TripTimelineEntry
    var showsDetails = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
            Label(timing.timeText, systemImage: timing.fixedArrival == nil ? "clock" : "pin")
                .font(.subheadline.weight(.medium)).foregroundStyle(.primary)
                .contentTransition(reduceMotion ? .identity : .numericText())
                .animation(reduceMotion ? nil : .smooth(duration: 0.18), value: timing.timeText)
            if showsDetails { details }
            if let conflict = timing.conflictText {
                Label(conflict, systemImage: "exclamationmark.triangle").font(.footnote).foregroundStyle(.primary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
            Text(timing.visitText)
            if let allowance = timing.allowanceText { Text(allowance) }
            if let waiting = timing.waitingText { Text(waiting) }
        }.font(.caption).foregroundStyle(.secondary)
    }
}

#if DEBUG
#Preview("Visit times", traits: .sizeThatFitsLayout) {
    let trip = TripSchedulePreview.plan()
    if let timing = TripDayTimeline(day: trip.days[0], date: trip.startDate)?.entries.last {
        TripStopTimeView(timing: timing).padding()
    }
}
#Preview("Fixed arrival conflict · large text", traits: .sizeThatFitsLayout) {
    let trip = TripSchedulePreview.plan(overloaded: true)
    if let timeline = TripDayTimeline(day: trip.days[0], date: trip.startDate) {
        TripStopTimeView(timing: timeline.entries[1]).padding().frame(width: 300)
            .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
    }
}
#Preview("Visit timing details", traits: .sizeThatFitsLayout) {
    let trip = TripSchedulePreview.plan()
    if let timing = TripDayTimeline(day: trip.days[0], date: trip.startDate)?.entries.last {
        TripStopTimeView(timing: timing, showsDetails: true).padding()
    }
}
#endif

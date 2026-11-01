import SwiftUI
import TripDomain
import TripLocalization

struct TripPlanningScheduleSection: View {
    let draft: TripPlanningDraft

    var body: some View {
        Section {
            if let timeline = draft.timeline { TripScheduleSummaryView(timeline: timeline, showsTarget: true) }
            if let issue = draft.timeIssue { Label(issue, systemImage: "clock.badge.questionmark") }
            Text(TripText.planningAllowances.resource).font(.footnote).foregroundStyle(.secondary)
        } header: { Text(TripText.placeSchedule.resource) }
    }
}

#if DEBUG
#Preview("Schedule preview · warnings") {
    List { TripPlanningScheduleSection(draft: TripPlanningPreview.fixture().1) }
}
#Preview("Schedule preview · large text") {
    List { TripPlanningScheduleSection(draft: TripPlanningPreview.fixture().1) }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

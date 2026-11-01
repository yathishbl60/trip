import TripLocalization
import TripDomain
import SwiftUI

struct TripDaySection: View {
    let day: TripDay
    let trip: TripPlan
    let controller: TripController
    @Environment(\.editMode) private var editMode

    var body: some View {
        let timeline = controller.model.timeline(for: day, in: trip)
        Section {
            notes
            if let timeline, !day.stops.isEmpty { schedule(timeline) }
            if let issue = day.scheduleIssue(in: trip) { scheduleReview(issue) }
            TripJourneyRows(trip: trip, day: day, controller: controller)
            if editMode?.wrappedValue.isEditing != true { addItems }
        } header: { TripDayHeaderView(day: day, trip: trip, controller: controller) } footer: {
            if editMode?.wrappedValue.isEditing == true, !trip.events.isEmpty {
                Text(TripText.dragToArrangeYourTimelineEventTimesStayAs.resource)
            }
        }
    }

    private func scheduleReview(_ issue: String) -> some View {
        Button { controller.reviewSchedule(day: day, trip: trip) } label: {
            Label(TripText.reviewScheduleValue(issue).resource, systemImage: "clock.badge.exclamationmark")
                .font(.subheadline).foregroundStyle(.primary)
        }.buttonStyle(.plain)
    }

    private func schedule(_ timeline: TripDayTimeline) -> some View {
        Button { controller.beginDaySchedule(dayID: day.id, tripID: trip.id) } label: {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
                Text(TripText.placeSchedule.resource).font(.caption).foregroundStyle(.secondary)
                TripScheduleSummaryView(timeline: timeline)
                if !trip.events.isEmpty {
                    Text(TripText.eventsKeepTheirOwnTimesTheyAreNotIncluded.resource)
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: AppTheme.controlTarget, alignment: .leading).contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityHint(TripText.editDaySchedule.resource)
    }

    private var addItems: some View {
        TripDayAddRow(day: day, trip: trip, controller: controller)
    }

    @ViewBuilder private var notes: some View {
        if editMode?.wrappedValue.isEditing == true {
            TextField(TripText.notesForThisDay.resource, text: controller.dayNotes(day.id, tripID: trip.id), axis: .vertical)
                .lineLimit(1...4)
        } else if !day.notes.isEmpty {
            Text(day.notes).font(.subheadline).foregroundStyle(.secondary)
        }
    }
}

#if DEBUG
#Preview("Itinerary day") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    List { TripDaySection(day: trip.days[0], trip: trip, controller: TripController(model: model)) }
}
#Preview("Empty day · large text") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    List { TripDaySection(day: trip.days[1], trip: trip, controller: TripController(model: model)) }
        .dynamicTypeSize(.accessibility2)
}
#Preview("Timed itinerary · conflicts") {
    let model = TripSchedulePreview.planner(overloaded: true)
    let trip = model.library.trips[0]
    List { TripDaySection(day: trip.days[0], trip: trip, controller: TripController(model: model)) }
        .preferredColorScheme(.dark)
}
#Preview("Overnight itinerary · large text") {
    let model = TripSchedulePreview.planner(overnight: true)
    let trip = model.library.trips[0]
    List { TripDaySection(day: trip.days[0], trip: trip, controller: TripController(model: model)) }
        .dynamicTypeSize(.accessibility2)
}
#endif

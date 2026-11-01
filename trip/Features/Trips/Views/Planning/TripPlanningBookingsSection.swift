import SwiftUI
import TripDomain
import TripLocalization

struct TripPlanningBookingsSection: View {
    let draft: TripPlanningDraft

    var body: some View {
        if !draft.bookings.isEmpty {
            Section {
                ForEach(draft.bookings) { event in
                    booking(event)
                }
            } header: { Label(TripText.planningBookings.resource, systemImage: "lock") }
        }
    }

    private func booking(_ event: TripEvent) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
            Label(event.title, systemImage: event.kind.symbol).font(.headline)
            Text(TripEventPresentation(event: event, day: draft.day, trip: draft.trip).timeText)
                .font(.subheadline).foregroundStyle(.secondary)
            if let issue = event.clockIssue {
                Label(issue, systemImage: "exclamationmark.triangle").font(.footnote)
            }
        }.accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Fixed booking details") {
    List { TripPlanningBookingsSection(draft: TripPlanningPreview.fixture().1) }
}
#Preview("Fixed bookings · large text") {
    List { TripPlanningBookingsSection(draft: TripPlanningPreview.fixture().1) }
        .dynamicTypeSize(.accessibility2)
}
#endif

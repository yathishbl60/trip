import TripLocalization
import TripDomain
import SwiftUI

struct TripOverviewView: View {
    let trip: TripPlan
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Section {
            summary
            if !trip.notes.isEmpty { notes }
        }
    }

    private var summary: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: AppTheme.Spacing.medium))
            : AnyLayout(HStackLayout(alignment: .center, spacing: AppTheme.Spacing.medium))
        return layout {
            TripLibraryArtworkView(category: trip.coverCategory, date: trip.startDate, timeZone: trip.calendar.timeZone)
            summaryText
        }
        .padding(.vertical, AppTheme.Spacing.small)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }

    private var summaryText: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(trip.dateSummary).font(.headline)
            Text(trip.overviewStatistics).font(.subheadline).foregroundStyle(.secondary)
        }.fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var notes: some View {
        DisclosureGroup {
            Text(trip.notes).font(.subheadline).textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        } label: {
            Label(TripText.tripNotes.resource, systemImage: "note.text").font(.subheadline)
        }
    }
}

#if DEBUG
#Preview("Trip overview · local data") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        List { TripOverviewView(trip: model.library.trips[0]) }
    }
}
#Preview("Overview · large text, local data") {
    let model = PreviewFixtures.tripPlanner()
    List { TripOverviewView(trip: model.library.trips[0]) }
        .dynamicTypeSize(.accessibility2)
}
#Preview("Trip notes · narrow, local data") {
    let model = PreviewFixtures.tripPlanner()
    var trip = model.library.trips[0]
    trip.notes = "Leave room for a slow afternoon by the river. Confirm hotel check-in before departure."
    return List { TripOverviewView(trip: trip) }
        .frame(width: 320).preferredColorScheme(.dark)
}
#Preview("Screenshot regression · empty trip, dark, local") {
    let model = TripLayoutPreview.emptyPlanner()
    List { TripOverviewView(trip: model.library.trips[0]) }
        .frame(width: 393).preferredColorScheme(.dark)
}
#endif

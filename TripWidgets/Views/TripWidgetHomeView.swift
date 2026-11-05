import TripLocalization
import AppIntents
import TripDomain
import SwiftUI
import WidgetKit

struct TripWidgetHomeView: View {
    let entry: TripWidgetEntry
    let expanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: WidgetTheme.Spacing.tight) {
            Label(entry.title, systemImage: "suitcase.rolling")
                .font(.caption.weight(.semibold)).foregroundStyle(.secondary).lineLimit(1)
            Label(entry.stopTitle, systemImage: entry.item?.symbol ?? "suitcase.rolling")
                .font(.headline).lineLimit(2)
            Text(entry.detail).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            Spacer(minLength: 0)
            if entry.isTracking { progress }
            else if expanded { upcomingActions }
        }
        .tint(WidgetTheme.accent)
    }

    private var progress: some View {
        HStack {
            VStack(alignment: .leading, spacing: WidgetTheme.Spacing.tight) {
                ProgressView(value: Double(entry.visited), total: Double(max(entry.total, 1)))
                    .accessibilityHidden(true)
                Text(entry.progress).font(.caption2).foregroundStyle(.secondary)
            }
            if expanded { TripWidgetDirectionsLink(entry: entry) }
            if entry.isTracking, let stop = entry.stop, let plan = entry.plan, let day = entry.day {
                Button(intent: CompleteTripStopIntent(stopID: stop.id, tripID: plan.id, dayID: day.id)) {
                    Image(systemName: "checkmark").font(.headline)
                }
                .buttonStyle(.borderedProminent).buttonBorderShape(.circle).tint(WidgetTheme.accentFill)
                .accessibilityLabel(TripText.markValueVisited(stop.name).resource)
            }
        }
    }

    private var upcomingActions: some View {
        HStack(alignment: .bottom) {
            plannedPlaces.frame(maxWidth: .infinity, alignment: .leading)
            TripWidgetDirectionsLink(entry: entry)
        }
    }

    private var plannedPlaces: some View {
        VStack(alignment: .leading, spacing: WidgetTheme.Spacing.tight) {
            ForEach(entry.remaining) { item in
                if let plan = entry.plan, let url = TripSystemData.detailURL(tripID: plan.id, itemID: item.id) {
                    Link(destination: url) {
                        Label(item.title, systemImage: item.symbol).font(.caption2).lineLimit(1)
                    }
                }
            }
        }
        .foregroundStyle(.secondary)
    }
}

#if DEBUG
#Preview("Home Screen · sample") {
    TripWidgetHomeView(entry: TripWidgetFixtures.active, expanded: true)
        .padding().frame(width: 340, height: 150)
}
#Preview("Planned trip · sample") {
    TripWidgetHomeView(entry: TripWidgetFixtures.planned, expanded: false)
        .padding().frame(width: 170, height: 170)
}
#Preview("Visits finished · flight still ahead") {
    TripWidgetHomeView(entry: TripWidgetFixtures.flightAfterVisits, expanded: true)
        .padding().frame(width: 340, height: 150).preferredColorScheme(.dark)
}
#Preview("Directions and visit · medium, large text") {
    TripWidgetHomeView(entry: TripWidgetFixtures.active, expanded: true)
        .padding().frame(width: 340, height: 170).dynamicTypeSize(.accessibility1)
}
#endif

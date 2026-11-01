import SwiftUI
import TripDomain
import TripLocalization

struct TripPlanningVisitRow: View {
    let visit: TripPlanningVisit

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
            Label {
                Text("\(visit.number.formatted()). \(visit.stop.place.name)").font(.headline)
            } icon: { Image(systemName: visit.stop.place.category.symbol).foregroundStyle(visit.stop.place.category.color) }
            if visit.isNew { Text(TripText.planningNewVisit.resource).font(.caption).foregroundStyle(AppTheme.accent) }
            if visit.isFixed { Label(TripText.planningFixedArrival.resource, systemImage: "lock").font(.caption) }
            if let entry = visit.entry { Text(entry.timeText).font(.subheadline).foregroundStyle(.secondary) }
            ForEach(visit.warnings) { warning in
                Label(warning.text, systemImage: "exclamationmark.triangle").font(.footnote)
            }
        }
        .padding(.vertical, AppTheme.Spacing.tight)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Visit with arrival warning", traits: .sizeThatFitsLayout) {
    TripPlanningVisitRow(visit: TripPlanningPreview.fixture().1.visits[1]).padding()
}
#Preview("New visit · large text", traits: .sizeThatFitsLayout) {
    TripPlanningVisitRow(visit: TripPlanningPreview.fixture(inserting: true).1.visits[0])
        .padding().dynamicTypeSize(.accessibility2)
}
#endif

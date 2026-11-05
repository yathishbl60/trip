import SwiftUI
import TripDomain

struct TripLookupResultView: View {
    let result: TripDetailResult

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
            Label(result.item.title, systemImage: result.item.symbol).font(.headline)
            Text(result.item.timeText).font(.subheadline)
            if !result.item.detail.isEmpty { Text(result.item.detail).font(.subheadline).textSelection(.enabled) }
            Text(result.source).font(.caption).foregroundStyle(.secondary)
        }
        .padding(.vertical, AppTheme.Spacing.tight)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Saved details · source reference") {
    let plan = TripSurfacePlan(TripJourneyPreview.plan())
    let results = TripDetailQuery(category: .stays).results(in: plan)
    return List { ForEach(results) { TripLookupResultView(result: $0) } }
}
#endif

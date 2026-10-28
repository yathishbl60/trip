import SwiftUI
import AppIntents
import TripDomain
import TripLocalization

struct TripAnswerView: View {
    let answer: TripDetailAnswer

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text(answer.plan.title).font(.headline)
            Text(answer.scope).font(.caption).foregroundStyle(.secondary)
            if answer.results.isEmpty { Text(answer.summary).font(.subheadline) }
            ForEach(answer.results.prefix(3)) { result in
                if let url = TripSystemData.detailURL(tripID: answer.plan.id, itemID: result.id) {
                    Link(destination: url) { TripLookupResultView(result: result) }
                        .appEntityIdentifier(EntityIdentifier(for: SavedTripDetailEntity.self,
                            identifier: TripDetailIdentity(tripID: answer.plan.id, itemID: result.id).rawValue))
                }
            }
            if let url = TripSystemData.tripURL(answer.plan.id) {
                Link(TripText.openItinerary.text, destination: url).buttonStyle(.bordered)
            }
        }.padding().privacySensitive()
    }
}

#if DEBUG
#Preview("Saved answer · stays") {
    let plan = TripSurfacePlan(TripJourneyPreview.plan())
    TripAnswerView(answer: TripDetailAnswer(plan: plan, query: TripDetailQuery(category: .stays)))
        .frame(width: 340)
}
#Preview("Saved answer · unsupported, large text") {
    let plan = TripSurfacePlan(TripJourneyPreview.plan())
    TripAnswerView(answer: TripDetailAnswer(plan: plan, query: TripDetailQuery(category: .unsupported)))
        .frame(width: 320).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif

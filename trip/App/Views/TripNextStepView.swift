import TripLocalization
import SwiftUI
import TripDomain
import AppIntents

struct TripNextStepView: View {
    let next: TripNextStep

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text(next.plan.title).font(.subheadline).foregroundStyle(.secondary)
            if let item = next.item, let day = next.day {
                Label(next.heading, systemImage: item.symbol).font(.subheadline)
                Text(item.title).font(.headline)
                Text(TripText.dayValueValue(TripText.number(day.number), item.timeText).resource).font(.subheadline).foregroundStyle(.secondary)
                actions(item)
                    .appEntityIdentifier(EntityIdentifier(for: SavedTripDetailEntity.self,
                        identifier: TripDetailIdentity(tripID: next.plan.id, itemID: item.id).rawValue))
            } else {
                Text(next.summary).font(.headline)
                if let url = TripSystemData.tripURL(next.plan.id) { Link(TripText.openItinerary.text, destination: url) }
            }
        }.padding().privacySensitive()
    }

    private func actions(_ item: TripSurfaceItem) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack { links(item) }
            VStack(alignment: .leading) { links(item) }
        }.buttonStyle(.bordered).buttonSizing(.fitted)
    }

    @ViewBuilder private func links(_ item: TripSurfaceItem) -> some View {
        if let url = TripSystemData.detailURL(tripID: next.plan.id, itemID: item.id) {
            Link(TripText.openDetails.text, destination: url)
        }
        if let coordinate = next.coordinate, let url = TripSystemData.directionsURL(coordinate) {
            Link(TripText.directions.text, destination: url).accessibilityLabel(TripText.directionsToValueInMaps(item.title).resource)
        }
    }
}

#if DEBUG
#Preview("Next saved step · local, large text") {
    let plan = TripSurfacePlan(TripJourneyPreview.plan())
    TripNextStepView(next: TripNextStep(plan: plan, journey: nil, at: plan.startDate))
        .frame(width: 320).dynamicTypeSize(.accessibility2)
}
#Preview("Next step · no day today") {
    let plan = TripSurfacePlan(TripJourneyPreview.plan())
    TripNextStepView(next: TripNextStep(plan: plan, journey: nil, at: .distantPast))
}
#endif

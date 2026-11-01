import TripLocalization
import SwiftUI
import TripDomain

struct TripStopOrderSummary: View {
    let proposal: TripStopOrderProposal
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Section {
            Label(proposal.hasImprovement ? TripText.lessBacktracking.text : TripText.keepYourCurrentOrder.text,
                  systemImage: proposal.hasImprovement ? "list.number" : "checkmark.circle")
                .font(.headline)
            distanceLayout { distances }.fixedSize(horizontal: false, vertical: true)
        } footer: {
            Text(TripText.straightLineDistancesTravelTimesOpeningHoursAndReservations.resource)
        }
    }

    private var distanceLayout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: AppTheme.Spacing.large))
            : AnyLayout(HStackLayout(alignment: .top, spacing: AppTheme.Spacing.edge))
    }

    private var distances: some View {
        Group {
            distance(TripText.current.text, meters: proposal.originalDistance)
            if proposal.hasImprovement { distance(TripText.suggested.text, meters: proposal.suggestedDistance) }
        }
    }

    private func distance(_ title: String, meters: Double) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
            Text(title).font(.subheadline).foregroundStyle(.secondary)
            Text(Measurement(value: meters, unit: UnitLength.meters),
                 format: .measurement(width: .abbreviated, usage: .road))
                .font(.title2.weight(.semibold)).fixedSize(horizontal: false, vertical: true)
        }
    }
}

#if DEBUG
#Preview("Shorter order") {
    let day = PreviewFixtures.tripPlanner().library.trips[0].days[0]
    List {
        TripStopOrderSummary(proposal: TripStopOrderProposal(day: day, suggestedIDs: day.stops.map(\.id),
            originalDistance: 8500, suggestedDistance: 5400))
    }
}
#Preview("No change · large text") {
    let day = PreviewFixtures.tripPlanner().library.trips[0].days[0]
    List {
        TripStopOrderSummary(proposal: TripStopOrderProposal(day: day, suggestedIDs: day.stops.map(\.id),
            originalDistance: 5400, suggestedDistance: 5400))
    }.dynamicTypeSize(.accessibility2)
}
#endif

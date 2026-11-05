import TripDomain
import SwiftUI

struct TripRowView: View {
    let trip: TripPlan
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Group {
            if typeSize.isAccessibilitySize { VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) { content } }
            else { HStack(alignment: .top, spacing: AppTheme.Spacing.large) { content } }
        }
        .padding(.vertical, AppTheme.Spacing.small)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var content: some View {
        TripLibraryArtworkView(category: trip.coverCategory, date: trip.startDate, timeZone: trip.calendar.timeZone)
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
            Text(trip.title).font(.headline).foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Text(trip.dateSummary).font(.subheadline).foregroundStyle(.secondary)
            Text("\(trip.dayCountText) · \(trip.savedPlaceCountText)")
                .font(.caption.weight(.medium)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Trip card", traits: .sizeThatFitsLayout) {
    TripRowView(trip: TripPlan(title: "A weekend in Bangkok")).padding()
}
#Preview("Long trip title · dark", traits: .sizeThatFitsLayout) {
    TripRowView(trip: TripPlan(title: "A slow journey through northern Thailand"))
        .padding().preferredColorScheme(.dark)
}
#Preview("Trip row · accessibility", traits: .sizeThatFitsLayout) {
    TripRowView(trip: TripPlan(title: "A slow journey through northern Thailand"))
        .padding().dynamicTypeSize(.accessibility2)
}

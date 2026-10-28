import TripLocalization
import SwiftUI
import TripDomain

struct TripDayBriefingView: View {
    let briefing: TripDayBriefing
    var weather: TripDayWeatherSummary?
    var includeWeather = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(briefing.plan.title).font(.headline)
            Text(briefing.heading).font(.subheadline).foregroundStyle(.secondary)
            if briefing.items.isEmpty { Text(TripText.nothingPlannedForThisDate.resource) }
            ForEach(Array(briefing.items.prefix(3))) { item in
                detailLink(item)
            }
            if let weather { TripDayWeatherSummaryView(weather: weather) }
            TripDayBriefingNavigation(briefing: briefing, includeWeather: includeWeather)
        }.padding().privacySensitive()
    }

    @ViewBuilder private func detailLink(_ item: TripSurfaceItem) -> some View {
        if let url = TripSystemData.detailURL(tripID: briefing.plan.id, itemID: item.id) {
            Link(destination: url) {
                VStack(alignment: .leading, spacing: 4) {
                    Label(item.title, systemImage: item.symbol).font(.subheadline.weight(.semibold))
                    Text(item.timeText).font(.caption).foregroundStyle(.secondary)
                }
            }.buttonStyle(.plain).accessibilityHint(TripText.openThisSavedItineraryDetail.resource)
        }
    }
}

#if DEBUG
#Preview("Siri · trip day briefing") {
    let trip = TripJourneyPreview.plan()
    return TripDayBriefingView(briefing: TripDayBriefing(plan: TripSurfacePlan(trip), date: trip.startDate))
}
#Preview("Siri · date outside itinerary") {
    let trip = TripJourneyPreview.plan()
    return TripDayBriefingView(briefing: TripDayBriefing(plan: TripSurfacePlan(trip), date: .distantPast))
        .dynamicTypeSize(.accessibility2)
}
#endif

import TripLocalization
import AppIntents
import SwiftUI
import TripDomain

struct TripDayBriefingNavigation: View {
    let briefing: TripDayBriefing
    var includeWeather = false

    var body: some View {
        HStack {
            if let date = briefing.previousDate {
                Button(intent: ShowTripDaySnippetIntent(tripID: briefing.plan.id, date: date, includeWeather: includeWeather)) {
                    Label(TripText.previousDay.resource, systemImage: "chevron.left")
                }.labelStyle(.iconOnly)
            }
            Spacer()
            if let url = TripSystemData.tripURL(briefing.plan.id) { Link(TripText.openItinerary.text, destination: url) }
            Spacer()
            if let date = briefing.nextDate {
                Button(intent: ShowTripDaySnippetIntent(tripID: briefing.plan.id, date: date, includeWeather: includeWeather)) {
                    Label(TripText.nextDay.resource, systemImage: "chevron.right")
                }.labelStyle(.iconOnly)
            }
        }.buttonStyle(.bordered)
    }
}

#if DEBUG
#Preview("Siri day navigation · first day") {
    let trip = TripJourneyPreview.plan()
    return TripDayBriefingNavigation(briefing: TripDayBriefing(plan: TripSurfacePlan(trip), date: trip.startDate))
}
#endif

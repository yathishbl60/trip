import SwiftUI
import TripDomain
import TripLocalization

struct TripDayWeatherSummaryView: View {
    let weather: TripDayWeatherSummary

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Label(weather.text, systemImage: "cloud.sun").font(.caption)
            if let attribution = weather.attribution {
                TripWeatherAttributionView(attribution: attribution, issuedAt: weather.issuedAt)
            }
        }.privacySensitive()
    }
}

#if DEBUG
#Preview("Briefing weather · local forecast") {
    TripDayWeatherSummaryView(weather: TripDayWeatherSummary(
        text: "Apple Weather · Riverside park · 9:00 AM · 28° · 20%",
        attribution: TripWeatherPreview.attribution, issuedAt: TripWeatherPreview.visit.target.arrival))
    .padding()
}
#Preview("Briefing weather · unavailable") {
    TripDayWeatherSummaryView(weather: TripDayWeatherSummary(text: TripText.weatherLoadFailure.text))
        .padding().dynamicTypeSize(.accessibility2)
}
#endif

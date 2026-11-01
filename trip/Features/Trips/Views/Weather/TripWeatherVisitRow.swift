import Foundation
import SwiftUI
import TripDomain
import TripLocalization

struct TripWeatherVisitRow: View {
    let visit: TripWeatherVisit
    let timeZone: TimeZone

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(visit.target.name).font(.headline)
            Text(visit.target.arrival, format: visitTimeFormat)
                .font(.subheadline).foregroundStyle(.secondary)
            if let hour = visit.hour {
                measurements(hour)
                ForEach(hour.advice) { advice in Label(advice.label, systemImage: advice.symbol).font(.subheadline) }
            } else {
                Text(visit.didFail ? TripText.weatherLoadFailure.resource : TripText.weatherNoForecast.resource)
                    .font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, AppTheme.Spacing.tight)
    }

    private var visitTimeFormat: Date.FormatStyle {
        var format = Date.FormatStyle(date: .abbreviated, time: .shortened)
        format.timeZone = timeZone
        return format
    }

    private func measurements(_ hour: TripWeatherHour) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
            Label {
                Text(Measurement(value: hour.temperatureCelsius, unit: UnitTemperature.celsius),
                     format: .measurement(width: .abbreviated, usage: .weather))
            } icon: { Image(systemName: hour.symbol).accessibilityHidden(true) }
            LabeledContent(TripText.weatherPrecipitation.resource) { Text(hour.precipitationChance, format: .percent) }
            LabeledContent(TripText.weatherWind.resource) {
                Text(Measurement(value: hour.windKilometersPerHour, unit: UnitSpeed.kilometersPerHour),
                     format: .measurement(width: .abbreviated, usage: .general))
            }
        }
        .font(.subheadline)
    }
}

#if DEBUG
#Preview("Visit forecast · rain") {
    List { TripWeatherVisitRow(visit: TripWeatherPreview.visit, timeZone: .gmt) }
}
#endif

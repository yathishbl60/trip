import Foundation
import TripLocalization

public nonisolated enum TripWeatherBriefing {
    /// Use only an hour actually returned by the forecast, never a nearby day substituted for a missing date.
    public static func summary(for target: TripWeatherTarget, forecast: TripWeatherForecast,
                               timeZoneID: String) -> String? {
        guard let hour = forecast.hour(containing: target.arrival) else { return nil }
        let temperature = Measurement(value: hour.temperatureCelsius, unit: UnitTemperature.celsius)
            .formatted(.measurement(width: .abbreviated, usage: .weather))
        let rain = "\(TripText.weatherPrecipitation.text): \(hour.precipitationChance.formatted(.percent))"
        let zone = TimeZone(identifier: timeZoneID) ?? .gmt
        let time = target.arrival.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened, timeZone: zone))
        return [TripText.weatherAppleWeather.text, target.name, time, temperature, rain].joined(separator: " · ")
    }
}

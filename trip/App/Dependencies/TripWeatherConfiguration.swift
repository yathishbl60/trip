import Foundation
import TripDomain
import TripLocalization

/// Enable only alongside WeatherKit capability and a provisioning profile that grants its entitlement.
nonisolated enum TripWeatherConfiguration {
    static var isEnabled: Bool {
        Bundle.main.object(forInfoDictionaryKey: "TripWeatherEnabled") as? Bool == true
    }
}

/// Personal Team builds keep the workflow available without attempting an unauthorized service request.
nonisolated struct UnavailableTripWeatherService: TripWeatherProviding {
    var availabilityIssue: String? { TripText.weatherNotEnabledInBuild.text }

    func forecast(at coordinate: Coordinate, during interval: DateInterval) async throws -> TripWeatherForecast {
        throw TripWeatherFailure.configurationUnavailable
    }
}

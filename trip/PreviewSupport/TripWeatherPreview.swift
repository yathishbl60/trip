#if DEBUG
import Foundation
import TripDomain

@MainActor enum TripWeatherPreview {
    static let date = DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(identifier: "Asia/Bangkok"),
                                     year: 2026, month: 11, day: 1, hour: 9).date!
    private static let visitID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    static var attribution: TripWeatherAttribution {
        TripWeatherAttribution(legalURL: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!,
                               lightMarkURL: nil, darkMarkURL: nil)
    }

    static var visit: TripWeatherVisit {
        let target = TripWeatherTarget(id: visitID, name: "Lumphini Park", coordinate: .bangkok, arrival: date)
        let hour = TripWeatherHour(date: date, symbol: "cloud.rain", temperatureCelsius: 30, apparentCelsius: 34,
                                   precipitationChance: 0.7, windKilometersPerHour: 12)
        return TripWeatherVisit(target: target, hour: hour)
    }

    static func model(fails: Bool = false, availabilityIssue: String? = nil) -> TripWeatherModel {
        let model = TripWeatherModel(service: PreviewTripWeatherService(fails: fails, availabilityIssue: availabilityIssue))
        let trip = plan
        model.prepare(trip: trip, day: trip.days[0])
        return model
    }

    static var plan: TripPlan {
        var trip = TripPlan(title: "Bangkok Weekend")
        trip.timeZoneID = "Asia/Bangkok"
        trip.startDate = date
        trip.days[0].schedule = TripDaySchedule()
        trip.days[0].stops = [PreviewFixtures.hotel, PreviewFixtures.longName, PreviewFixtures.place(.park)].map(TripStop.init)
        return trip
    }

    static func presentedPlanner() -> TripModel {
        let trip = plan
        let model = PreviewTripServices.makeTrips([trip])
        model.beginWeather(dayID: trip.days[0].id, tripID: trip.id)
        return model
    }
}

nonisolated struct PreviewTripWeatherService: TripWeatherProviding {
    var fails = false
    var availabilityIssue: String?

    func forecast(at coordinate: Coordinate, during interval: DateInterval) async throws -> TripWeatherForecast {
        guard availabilityIssue == nil else { throw TripWeatherFailure.configurationUnavailable }
        if fails { throw TripWeatherFailure.unavailable }
        let hour = TripWeatherHour(date: interval.start, symbol: "cloud.rain", temperatureCelsius: 30,
                                   apparentCelsius: 34, precipitationChance: 0.7, windKilometersPerHour: 12)
        let attribution = TripWeatherAttribution(legalURL: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!,
                                                 lightMarkURL: nil, darkMarkURL: nil)
        return TripWeatherForecast(hours: [hour], issuedAt: interval.start, expiresAt: interval.end, attribution: attribution)
    }
}
#endif

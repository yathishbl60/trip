import TripDomain
import TripIntegrations

extension AppTripServices {
    static let weather: any TripWeatherProviding = makeWeather()
    static let bookingReader: any TripBookingReading = TripBookingReader()
    static let systemActions: any TripSystemActionProviding = makeSystemActionProvider()

    static func makeBookingImport() -> TripBookingImportModel {
        TripBookingImportModel(reader: bookingReader)
    }

    static func makeSystemActions(library: TripLibraryModel) -> TripSystemActionsModel {
        TripSystemActionsModel(service: systemActions, library: library)
    }

    private static func makeWeather() -> any TripWeatherProviding {
        guard TripWeatherConfiguration.isEnabled else { return UnavailableTripWeatherService() }
        return AppleTripWeatherService()
    }

    private static func makeSystemActionProvider() -> AppleTripSystemActions {
        let service = AppleTripSystemActions()
        #if os(iOS)
        service.openAlarm = { OpenTripBookingAlarmIntent(tripID: $0.tripID, eventID: $0.eventID) }
        #endif
        return service
    }
}

import SwiftUI
import TripDomain
import Foundation

extension TripController {
    var weatherPresentation: Binding<TripWeatherDestination?> {
        let destination = model.presentation.weatherDestination
        return Binding(get: { model.presentation.weatherDestination }, set: { value in
            if value == nil, model.presentation.weatherDestination == destination {
                model.presentation.weatherDestination = nil
                model.weather.cancel()
            }
        })
    }

    func beginWeather(dayID: UUID, tripID: UUID) { model.beginWeather(dayID: dayID, tripID: tripID) }
    func refreshWeather(_ destination: TripWeatherDestination) { model.refreshWeather(destination) }
    func reviewWeatherSchedule(_ destination: TripWeatherDestination) { model.reviewWeatherSchedule(destination) }
    func weatherDismissed() { model.weatherDismissed() }
}

import Foundation
import TripDomain

extension TripModel {
    func beginWeather(dayID: UUID, tripID: UUID) {
        guard !hasEditingSession, let trip = library.trip(tripID),
              let day = trip.days.first(where: { $0.id == dayID }) else { return }
        weather.reviewDestination = nil
        weather.prepare(trip: trip, day: day)
        presentation.weatherDestination = TripWeatherDestination(tripID: tripID, dayID: dayID)
    }

    func weatherRequest(for destination: TripWeatherDestination) -> TripWeatherRequest? {
        guard let trip = library.trip(destination.tripID),
              let day = trip.days.first(where: { $0.id == destination.dayID }) else { return nil }
        return TripWeatherRequest(trip: trip, day: day)
    }

    func refreshWeather(_ destination: TripWeatherDestination) {
        guard presentation.weatherDestination == destination else { return }
        guard let trip = library.trip(destination.tripID),
              let day = trip.days.first(where: { $0.id == destination.dayID }) else {
            presentation.weatherDestination = nil
            weather.cancel()
            return
        }
        weather.prepare(trip: trip, day: day)
    }

    func reviewWeatherSchedule(_ destination: TripWeatherDestination) {
        guard presentation.weatherDestination == destination else { return }
        weather.reviewDestination = destination
        presentation.weatherDestination = nil
    }

    /// The native weather sheet must finish dismissing before presenting another editing session.
    func weatherDismissed() {
        weather.cancel()
        guard let destination = weather.reviewDestination else { return }
        weather.reviewDestination = nil
        guard !hasEditingSession, let trip = library.trip(destination.tripID),
              let day = trip.days.first(where: { $0.id == destination.dayID }) else { return }
        if trip.needsTimeZoneReview { beginEdit(trip.id) }
        else if day.schedule == nil { beginDaySchedule(dayID: day.id, tripID: trip.id) }
        else { beginPlanning(dayID: day.id, tripID: trip.id) }
    }
}

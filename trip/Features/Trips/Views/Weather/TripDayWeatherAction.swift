import SwiftUI
import TripDomain
import TripLocalization

struct TripDayWeatherAction: View {
    let day: TripDay
    let trip: TripPlan
    let controller: TripController

    var body: some View {
        Button(TripText.weatherForDay.resource, systemImage: "cloud.sun") {
            controller.beginWeather(dayID: day.id, tripID: trip.id)
        }
    }
}

#if DEBUG
#Preview("Weather day action") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    TripDayWeatherAction(day: trip.days[0], trip: trip, controller: TripController(model: model))
}
#endif

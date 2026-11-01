import SwiftUI
import TripDomain

struct TripWeatherPresentationView: View {
    let destination: TripWeatherDestination
    let controller: TripController

    var body: some View {
        TripWeatherView(model: controller.model.weather) { controller.reviewWeatherSchedule(destination) }
            .onChange(of: controller.model.weatherRequest(for: destination), initial: true) {
                controller.refreshWeather(destination)
            }
    }
}

extension View {
    func tripWeatherSheet(_ controller: TripController) -> some View {
        sheet(item: controller.weatherPresentation, onDismiss: controller.weatherDismissed) { destination in
            TripWeatherPresentationView(destination: destination, controller: controller)
        }
    }
}

#if DEBUG
#Preview("Day weather presentation · local provider") {
    let model = TripWeatherPreview.presentedPlanner()
    let trip = model.library.trips[0]
    TripWeatherPresentationView(destination: TripWeatherDestination(tripID: trip.id, dayID: trip.days[0].id),
                                controller: TripController(model: model))
}
#endif

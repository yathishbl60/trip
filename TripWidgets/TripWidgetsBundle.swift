import SwiftUI
import WidgetKit

@main struct TripWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TripItineraryWidget()
        TripReadinessWidget()
        #if os(iOS)
        TripDayActivityWidget()
        TripLauncherControl()
        #endif
    }
}

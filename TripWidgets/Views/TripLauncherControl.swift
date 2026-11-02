import TripLocalization
#if os(iOS)
import AppIntents
import SwiftUI
import WidgetKit

struct TripLauncherControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(kind: TripSystemData.controlKind, intent: TripLauncherConfiguration.self) { configuration in
            ControlWidgetButton(action: OpenTripControlIntent(tripID: configuration.trip?.id,
                                                              surface: configuration.destination.rawValue)) {
                Label(configuration.trip?.name ?? TripText.chooseATrip.text,
                      systemImage: configuration.destination.symbol)
            }
        }
        .displayName("open_saved_trip2")
        .promptsForUserConfiguration()
        .description("open_your_itinerary_checklist_or_next_item_from_control")
    }
}
#endif

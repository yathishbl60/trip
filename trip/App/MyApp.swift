import TripLocalization
import SwiftUI
import Foundation

@main struct MyApp: App {
    init() {
        if !AppTestHost.isEnabled { AppRuntime.installControls() }
    }

    var body: some Scene {
        WindowGroup(TripText.appName.resource, id: "workspace") {
            AppEntryView()
        }
        .defaultSize(width: 1100, height: 760)
        .commands { TripCommands() }
        WindowGroup(TripText.appName.resource, id: "trip", for: UUID.self) { $tripID in
            AppEntryView(initialTripID: tripID)
        }
        .defaultSize(width: 1100, height: 760)
    }
}

import TripLocalization
import SwiftUI
import Foundation

@main struct MyApp: App {
    init() { AppRuntime.installControls() }

    var body: some Scene {
        WindowGroup(TripText.appName.resource, id: "workspace") {
            ContentView()
        }
        .defaultSize(width: 1100, height: 760)
        .commands { TripCommands() }
        WindowGroup(TripText.appName.resource, id: "trip", for: UUID.self) { $tripID in
            ContentView(initialTripID: tripID)
        }
        .defaultSize(width: 1100, height: 760)
    }
}

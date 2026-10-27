import TripLocalization
import SwiftUI

struct TripCommands: Commands {
    @FocusedValue(AppModel.self) private var model
    @Environment(\.openWindow) private var openWindow
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button(TripText.newTrip.resource) { model?.request(.newTrip) }.keyboardShortcut("n")
                .disabled(model?.trips.library.canCreate != true || model?.trips.library.isReady != true)
                .disabled(model?.trips.hasEditingSession == true)
            if supportsMultipleWindows {
                Button(TripText.newWindow.resource) { openWindow(id: "workspace") }.keyboardShortcut("n", modifiers: [.command, .shift])
            }
        }
        CommandMenu(TripText.navigate.resource) {
            Button(TripText.explore.resource) { model?.request(.explore) }.keyboardShortcut("1")
            Button(TripText.trips.resource) { model?.request(.trips) }.keyboardShortcut("2")
        }
    }
}

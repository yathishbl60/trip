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
        navigation
    }

    private var navigation: some Commands {
        CommandMenu(TripText.navigate.resource) {
            Button(TripText.explore.resource) { model?.request(.explore) }.keyboardShortcut("1")
                .disabled(model?.trips.hasEditingSession == true)
            Button(TripText.trips.resource) { model?.request(.trips) }.keyboardShortcut("2")
                .disabled(model?.trips.hasEditingSession == true)
            tripNavigation.disabled(model?.trips.hasEditingSession == true)
        }
    }

    @ViewBuilder private var tripNavigation: some View {
        if let model, let id = model.trips.selectedTripID {
            Divider()
            Button(TripText.itinerary.resource) { model.request(.section(id, .itinerary)) }.keyboardShortcut("3")
            Button(TripText.today.resource) { model.request(.section(id, .today)) }.keyboardShortcut("4")
            Button(TripText.checklist.resource) { model.request(.section(id, .checklist)) }.keyboardShortcut("5")
            Button(TripText.askMyTrip.resource) { model.request(.section(id, .details)) }.keyboardShortcut("f", modifiers: [.command, .shift])
        }
    }
}

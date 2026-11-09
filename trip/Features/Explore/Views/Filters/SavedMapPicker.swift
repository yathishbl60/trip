import SwiftUI
import TripDomain
import TripLocalization

struct SavedMapPicker: View {
    let controller: SavedMapController

    var body: some View {
        Picker(TripText.showOnMap.resource, selection: controller.scope) {
            Text(TripText.allPlaces.resource).tag(SavedMapScope.all)
            Text(TripText.savedPlaces.resource).tag(SavedMapScope.saved)
            ForEach(controller.model.environment.savedCatalog()) { group in
                Text(group.title).tag(SavedMapScope.trip(group.id))
            }
        }
    }
}

#if DEBUG
#Preview("Saved map filter · native menu") {
    Menu("Map") { SavedMapPicker(controller: SavedMapController(model: PlaceDetailPreviewFixtures.saved())) }
}
#endif

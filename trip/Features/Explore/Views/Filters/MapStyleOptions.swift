import TripLocalization
import SwiftUI

struct MapStyleOptions: View {
    let controller: MapAppearanceController

    var body: some View {
        Section(TripText.appearance.resource) {
            Picker(TripText.mapStyle.resource, selection: controller.style) {
                ForEach(MapStyleChoice.allCases) { style in
                    Label(style.title, systemImage: style.symbol).tag(style)
                }
            }
            if controller.model.style.supportsTraffic {
                Toggle(TripText.showTraffic.resource, systemImage: "car.side", isOn: controller.showsTraffic)
            }
        }
    }
}

#Preview("Map style choices") {
    Menu("Map options") { MapStyleOptions(controller: MapAppearanceController(model: MapAppearanceModel())) }
}
#Preview("Map styles · satellite") {
    let model = MapAppearanceModel()
    model.select(.satellite)
    return Menu("Map options") { MapStyleOptions(controller: MapAppearanceController(model: model)) }
}

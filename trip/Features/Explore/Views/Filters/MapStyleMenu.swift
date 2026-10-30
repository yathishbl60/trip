import TripLocalization
import SwiftUI

struct MapStyleMenu: View {
    let model: MapAppearanceModel

    var body: some View {
        Menu(TripText.mapStyle.resource, systemImage: "globe") {
            MapStyleOptions(controller: MapAppearanceController(model: model))
        }
        .accessibilityValue(model.style.title)
    }
}

#Preview("Style while viewing a place") { MapStyleMenu(model: MapAppearanceModel()) }
#Preview("Style while routing · dark") { MapStyleMenu(model: MapAppearanceModel()).preferredColorScheme(.dark) }

import SwiftUI

@MainActor struct MapAppearanceController {
    let model: MapAppearanceModel

    var style: Binding<MapStyleChoice> {
        Binding(get: { model.style }, set: model.select)
    }

    var showsTraffic: Binding<Bool> {
        Binding(get: { model.showsTraffic }, set: model.setTraffic)
    }

    func restore(style: String, showsTraffic: Bool) { model.restore(style: style, showsTraffic: showsTraffic) }
}

import SwiftUI

/// Each window restores its own appearance without sharing camera or selection state.
struct MapAppearanceRestoration: ViewModifier {
    let controller: MapAppearanceController
    @SceneStorage("explore.mapStyle") private var style = MapStyleChoice.standard.rawValue
    @SceneStorage("explore.showsTraffic") private var showsTraffic = false

    func body(content: Content) -> some View {
        content
            .onAppear { controller.restore(style: style, showsTraffic: showsTraffic) }
            .onChange(of: controller.model.style) { style = controller.model.style.rawValue }
            .onChange(of: controller.model.showsTraffic) { showsTraffic = controller.model.showsTraffic }
    }
}

#Preview("Appearance restoration") {
    let model = MapAppearanceModel()
    return Menu("Map options") { MapStyleOptions(controller: MapAppearanceController(model: model)) }
        .modifier(MapAppearanceRestoration(controller: MapAppearanceController(model: model)))
}

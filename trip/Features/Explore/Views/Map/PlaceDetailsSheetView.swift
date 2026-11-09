import CoreGraphics
import TripDomain
import SwiftUI

/// One presented sheet updates its content when another annotation is selected.
struct PlaceDetailsSheetView<Detail: View>: View {
    let model: ExploreModel
    private let detail: (Place, PlaceController) -> Detail

    init(model: ExploreModel, @ViewBuilder detail: @escaping (Place, PlaceController) -> Detail) {
        self.model = model
        self.detail = detail
    }

    var body: some View {
        panel.modifier(PlacePanelPresentation(controller: PlaceController(model: model)))
    }

    @ViewBuilder private var panel: some View {
        if model.browse.isPresented {
            MapBrowseNavigation(controller: MapBrowseController(model: model), detail: detail)
        } else if let root = model.selection.rootPlace, let selectedID = model.selectedPlace?.id {
            measuredDetails(root, selectedID: selectedID, revision: model.selection.revision)
        }
    }

    private func measuredDetails(_ root: Place, selectedID: String, revision: Int) -> some View {
        detail(root, PlaceController(model: model))
            .onGeometryChange(for: PlacePanelMeasurement.self) { geometry in
                PlacePanelMeasurement(frame: geometry.frame(in: .global), placeID: selectedID, revision: revision)
            } action: { measurement in
                MapController(model: model).detailAreaChanged(measurement.frame, placeID: measurement.placeID,
                                                             revision: measurement.revision)
            }
            .id(root.id)
    }
}

private nonisolated struct PlacePanelMeasurement: Equatable, Sendable {
    let frame: CGRect
    let placeID: String
    let revision: Int
}

#if DEBUG
#Preview("Place details · local selection") {
    let model = PreviewFixtures.explore()
    model.select(PreviewFixtures.hotel)
    return PlaceDetailsSheetView(model: model) { place, controller in
        PlaceDetailView(place: place, controller: controller)
    }
}
#Preview("Switch selection · same sheet") {
    @Previewable @State var model = PreviewFixtures.explore()
    PlaceDetailsSheetView(model: model) { place, controller in
        PlaceDetailView(place: place, controller: controller)
    }
    .onAppear { model.select(PreviewFixtures.hotel) }
    .overlay(alignment: .bottom) {
        Button("Select another place") {
            PlaceController(model: model).select(PreviewFixtures.unrated)
        }.buttonStyle(.borderedProminent).padding()
    }
}
#Preview("Crowded annotation · details first") {
    let model = PreviewFixtures.explore()
    model.select(PreviewFixtures.hotel)
    model.selection.nearbyPlaces = [PreviewFixtures.hotel, PreviewFixtures.unrated, PreviewFixtures.longName]
    return PlaceDetailsSheetView(model: model) { place, controller in
        PlaceDetailView(place: place, controller: controller)
    }
}
#if os(iOS)
#Preview("Place sheet · short window, accessibility text", traits: .landscapeLeft) {
    @Previewable @State var presented = true
    let model = PreviewFixtures.explore()
    model.select(PreviewFixtures.longName)
    return Color.clear.sheet(isPresented: $presented) {
        PlaceDetailsSheetView(model: model) { place, controller in
            PlaceDetailView(place: place, controller: controller)
        }.dynamicTypeSize(.accessibility2)
    }
}
#endif
#endif

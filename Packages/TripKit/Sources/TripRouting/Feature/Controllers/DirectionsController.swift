#if os(iOS) || os(visionOS)
import SwiftUI
import TripDomain

@MainActor struct DirectionsController {
    let model: DirectionsModel
    init(model: DirectionsModel) { self.model = model }
    var directions: DirectionsModel { model }
    var mode: Binding<TravelMode> { Binding(get: { model.mode }, set: model.setMode) }
    var timing: Binding<DirectionsTiming> { Binding(get: { model.options.timing }, set: model.setTiming) }
    var date: Binding<Date> { Binding(get: { model.options.date }, set: model.setDate) }
    var avoidsTolls: Binding<Bool> { Binding(get: { model.options.avoidsTolls }, set: model.setTollAvoidance) }
    var avoidsHighways: Binding<Bool> { Binding(get: { model.options.avoidsHighways }, set: model.setHighwayAvoidance) }
    var selectedRoute: Binding<String?> {
        Binding(get: { model.selectedID }, set: { if let id = $0 { model.select(id) } })
    }

    func dismiss() {
        model.environment.close()
        model.dismiss()
    }

    func select(_ id: String) { model.select(id) }
    func showSteps() { model.showAuxiliary(.steps) }
    func showOptions() { model.showAuxiliary(.options) }
    func editStops() { model.showAuxiliary(.stops) }
    func changePlace(_ place: Place) { model.changePlace(place) }
    func removeStops(_ indices: IndexSet, in snapshot: [Place]) { model.removeStops(indices, in: snapshot) }
    func moveStops(_ indices: IndexSet, to offset: Int, in snapshot: [Place]) {
        model.moveStops(indices, to: offset, in: snapshot)
    }
    func retry() { model.retry() }

    func beginAddingStop() { model.beginAddingStop() }

    func openMaps(using action: OpenURLAction, completion: @escaping (Bool) -> Void) {
        guard let url = model.mapsURL else { return }
        action(url, completion: model.mapsHandoffCompletion(completion))
    }
}
#endif

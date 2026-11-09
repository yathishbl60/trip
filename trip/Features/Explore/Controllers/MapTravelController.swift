import SwiftUI
import TripDomain
import TripRouting

@MainActor struct MapTravelController {
    let model: MapTravelComparisonModel
    var origin: Binding<String> { Binding(get: { model.originID }, set: { model.originID = $0 }) }
    var mode: Binding<TravelMode> { Binding(get: { model.mode }, set: { model.mode = $0 }) }
    func toggle(_ place: Place) { model.toggle(place) }
    func retry() { model.revision += 1 }
    func load() async { await model.load() }
}

import SwiftUI
import MapKit
import TripDomain
import TripPlaces

@MainActor struct PlaceCardController {
    let model: PlaceCardModel

    var item: Binding<MKMapItem?> { Binding(get: { model.item }, set: { model.item = $0 }) }
    var failure: Binding<Bool> { Binding(get: { model.hasFailed }, set: { model.hasFailed = $0 }) }
    static func supports(_ place: Place) -> Bool { MapItemService.identifier(for: place) != nil }
    func open(_ place: Place) { model.open(place) }
    func cancel() { model.cancel() }
}

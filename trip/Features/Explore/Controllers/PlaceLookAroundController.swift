import TripDomain
import SwiftUI

@MainActor struct PlaceLookAroundController {
    let model: PlaceLookAroundModel

    func load(_ place: Place) { model.load(place.coordinate) }
    func cancel() { model.cancel() }
    func reset() { model.reset() }
    func showViewer() { model.setViewerPresented(true) }

    var viewerPresentation: Binding<Bool> {
        Binding(get: { model.isViewerPresented }, set: { model.setViewerPresented($0) })
    }
}

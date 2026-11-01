import SwiftUI
import MapKit
import TripDomain

@MainActor struct TripMapController {
    let model: TripMapModel

    var position: Binding<MapCameraPosition> {
        Binding(get: { model.position }, set: { model.position = $0 })
    }

    var selection: Binding<UUID?> {
        Binding(get: { model.selectedStopID }, set: { model.selectStop($0, focus: false, animated: false) })
    }

    func daySelection(reduceMotion: Bool) -> Binding<UUID?> {
        Binding(get: { model.day?.id }, set: { model.selectDay($0, animated: !reduceMotion) })
    }

    func selectStop(_ id: UUID, reduceMotion: Bool) {
        model.selectStop(id, focus: true, animated: !reduceMotion)
    }

    func recordCamera(_ camera: MapCamera) { model.recordCamera(camera) }

    func fit(reduceMotion: Bool) {
        model.fit(animated: !reduceMotion)
    }
    func reconcile() { model.reconcile() }
}

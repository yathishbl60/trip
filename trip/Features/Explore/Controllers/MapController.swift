import MapKit
import SwiftUI

@MainActor struct MapController {
    let model: ExploreModel

    var position: Binding<MapCameraPosition> {
        Binding(get: { model.camera.position }, set: model.receivePosition)
    }

    func changed(_ context: MapCameraUpdateContext, proxy: MapProxy) {
        model.cameraChanged(context, proxy: proxy)
    }

    func settled(_ context: MapCameraUpdateContext, proxy: MapProxy) {
        model.cameraSettled(context, proxy: proxy)
    }

    func refresh(using proxy: MapProxy) { model.refreshMap(using: proxy) }
    func resize(_ frame: CGRect) { model.resizeMap(frame) }
    func visibleAreaChanged(_ frame: CGRect) { model.visibleAreaChanged(frame) }
    func detailAreaChanged(_ frame: CGRect, placeID: String, revision: Int) {
        model.detailAreaChanged(frame, placeID: placeID, revision: revision)
    }
    func noticeAreaChanged(_ frame: CGRect) { model.noticeAreaChanged(frame) }
    func accessibility(scale: CGFloat, reduceMotion: Bool) {
        model.updateAccessibility(scale: scale, reduceMotion: reduceMotion)
    }
    func stop() { model.stop() }
}

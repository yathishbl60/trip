import TripRouting
import MapKit
import SwiftUI

extension ExploreModel {
    func receivePosition(_ position: MapCameraPosition) {
        camera.receivePosition(position)
        if position.positionedByUser { userMovedMap() }
        if position.followsUserLocation, !location.wantsUpdates { location.start() }
    }

    private func userMovedMap() {
        catalog.setSearchPresented(false)
        selection.userMoved()
        directions.stopFollowingRoute()
    }

    func refreshMap(using proxy: MapProxy) {
        if !revealSelection(using: proxy) { refreshLayout(using: proxy, force: true) }
    }
}

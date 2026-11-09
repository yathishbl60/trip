import TripDomain
import TripRouting
import MapKit
import SwiftUI

extension ExploreModel {
    var mapSheet: ExploreSheet? {
        if directions.isPresented { return .directions }
        return selectedPlace == nil && !browse.isPresented ? nil : .details
    }

    func showDirections(to place: Place) {
        browse.close()
        filters.isPresented = false
        environment.dismissSave()
        catalog.setSearchPresented(false)
        select(place)
        directions.begin(place, origin: location.currentCoordinate)
        requestProjection()
    }

    func showDirections(for places: [Place]) {
        guard let destination = places.last else { return }
        browse.close()
        filters.isPresented = false
        environment.dismissSave()
        catalog.setSearchPresented(false)
        select(destination)
        directions.beginItinerary(places, origin: location.currentCoordinate)
        requestProjection()
    }

    func directionsLocationChanged() {
        guard isActive, directions.isPresented, directions.waitsForLocation else { return }
        if let coordinate = location.currentCoordinate {
            directions.acceptLocation(coordinate)
        } else if !location.isFollowing, location.status != configuration.startingPointLabel {
            directions.fail(location.status)
        }
    }

    func dismissMapSheet() {
        browse.close()
        catalog.setSearchPresented(false)
        dismissDirections()
        select(nil)
    }

    func dismissDirections() {
        directions.cancelRouteFit()
        camera.sheetFrame = .null
        let wasRouting = directions.isPresented
        directions.dismiss()
        if wasRouting, !camera.position.followsUserLocation {
            location.wantsUpdates = false
            location.stop()
        }
    }

    func fitDirections() {
        guard let bounds = directions.routeBounds else { return }
        if camera.fitRoute(bounds) { directions.didFitRoute() }
    }

    func resumeDirections() {
        if location.wantsUpdates { location.start() }
        directions.resume()
    }
}

enum ExploreSheet: String, Identifiable {
    case details, directions
    var id: String { rawValue }
}

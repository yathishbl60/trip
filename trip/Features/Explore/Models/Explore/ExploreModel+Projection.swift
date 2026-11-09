import TripRouting
import TripDomain
import MapEngine
import MapKit
import SwiftUI
import CoreGraphics

extension ExploreModel {
    func captureProjection(using proxy: MapProxy) -> MapProjection? {
        MapPerformance.measure("Map projection") { makeProjection(using: proxy) }
    }

    private func makeProjection(using proxy: MapProxy) -> MapProjection? {
        guard let center = proxy.convert(CGPoint(x: camera.size.width / 2, y: camera.size.height / 2), from: .local),
              Coordinate(center).isValid else { return nil }
        let geometry = MapViewportGeometry(proxy: proxy, size: camera.size, center: Coordinate(center))
        let candidates = projectCandidates(proxy, center: Coordinate(center), coverage: geometry.cells)
        let points = projectMarkerPoints(candidates, using: proxy)
        let locationPoint = configuration.showsLocation
            ? location.currentCoordinate.flatMap { proxy.convert($0.location, to: .local) } : nil
        return MapProjection(candidates: candidates, points: points, locationPoint: locationPoint,
                             viewport: CGRect(origin: .zero, size: camera.size),
                             zoom: camera.zoomLevel(using: proxy), scale: camera.markerScale,
                             routeExclusions: routeExclusions(using: proxy),
                             browseRegion: geometry.region, center: Coordinate(center))
    }

    private func projectCandidates(_ proxy: MapProxy, center: Coordinate, coverage: [MapCandidateRegion]) -> [ProjectedPlace] {
        let viewport = CameraProjectionPolicy.candidateViewport(size: camera.size)
        let bounds = camera.projectionBounds ?? camera.initialProjectionBounds(using: proxy, center: center)
        let candidates = projectionCandidates(in: bounds, center: center, coverage: coverage)
        let excluded = directions.placeIDs
        return candidates.compactMap { candidate -> ProjectedPlace? in
            guard !excluded.contains(candidate.place.id) else { return nil }
            guard let point = proxy.convert(candidate.place.coordinate.location, to: .local),
                  point.x.isFinite, point.y.isFinite, viewport.contains(point) else { return nil }
            return ProjectedPlace(place: candidate.place, point: point)
        }
    }

    private func projectMarkerPoints(_ candidates: [ProjectedPlace], using proxy: MapProxy) -> [String: CGPoint] {
        var points = Dictionary(candidates.map { ($0.place.id, $0.point) }, uniquingKeysWith: { first, _ in first })
        for marker in layout.markers where points[marker.id] == nil {
            guard let point = proxy.convert(marker.place.coordinate.location, to: .local),
                  point.x.isFinite, point.y.isFinite else { continue }
            points[marker.id] = point
        }
        return points
    }

    func makeLayoutRequest(_ projection: MapProjection, isSettled: Bool) -> LayoutRequest {
        var exclusions = chromeExclusions + projection.routeExclusions
        if let point = projection.locationPoint, point.x.isFinite, point.y.isFinite {
            exclusions.append(MapViewportPolicy.locationExclusion(at: point))
        }
        return LayoutRequest(candidates: projection.candidates, viewport: projection.viewport,
                             exclusions: exclusions, zoom: projection.zoom, scale: projection.scale,
                             selectedID: selectedPlace?.id, generation: layout.generation, isSettled: isSettled,
                             previous: layout.history,
                             reservations: markerReservations(projection), policy: configuration.layout)
    }

    private func markerReservations(_ projection: MapProjection) -> [MarkerReservation] {
        guard !camera.reduceMotion else { return [] }
        let excluded = directions.placeIDs
        let selectedRect = selectionBounds(in: projection)
        return layout.markers.compactMap { marker in
            guard let point = projection.points[marker.id],
                  !excluded.contains(marker.id),
                  point.x.isFinite, point.y.isFinite,
                  marker.hasActiveReservation else { return nil }
            let reservation = marker.reservation(at: point)
            if marker.id != selectedPlace?.id, selectedRect?.intersects(reservation.rect) == true { return nil }
            return reservation
        }
    }

    private func selectionBounds(in projection: MapProjection) -> CGRect? {
        guard let id = selectedPlace?.id, let point = projection.points[id],
              let style = configuration.layout.styles(at: projection.zoom, selected: true).first else { return nil }
        let clearance = MarkerLayoutPolicy.entryAndPromotionClearance
        return MarkerGeometry(style: style, scale: projection.scale).bounds(at: point)
            .insetBy(dx: -clearance, dy: -clearance)
    }

}

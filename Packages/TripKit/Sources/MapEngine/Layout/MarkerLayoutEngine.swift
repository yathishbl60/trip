import Foundation
import CoreGraphics
#if !TRIP_STANDALONE
import TripDomain
#endif

/// History comes from the last displayed frame, never from cancelled work.
public actor MarkerLayoutEngine {
    public init() {}

    public func arrange(_ request: LayoutRequest) throws -> [MarkerPlacement] {
        try Task.checkCancellation()
        guard request.isValid else { return [] }
        var grid = try collisionGrid(for: request)
        var result: [MarkerPlacement] = []
        var photoCount = 0
        let zoomStyles = request.policy.styles(at: request.zoom)
        let photoLimit = request.policy.photoLimit(in: request.viewport)
        for candidate in try rank(request) {
            try Task.checkCancellation()
            guard result.count < request.policy.markerLimit else { break }
            guard let style = chooseStyle(for: candidate, in: request, avoiding: grid,
                                         from: zoomStyles, allowsPhoto: photoCount < photoLimit) else { continue }
            grid.insert(collisionBounds(for: candidate, style: style, in: request), id: candidate.place.id)
            result.append(MarkerPlacement(place: candidate.place, style: style))
            if style.hasPhoto { photoCount += 1 }
        }
        return result
    }

    private func collisionGrid(for request: LayoutRequest) throws -> CollisionGrid {
        var grid = CollisionGrid()
        for rect in request.exclusions {
            try Task.checkCancellation()
            guard rect.isFinite, !rect.isEmpty else { continue }
            let clipped = rect.intersection(request.viewport)
            if clipped.isFinite && !clipped.isEmpty { grid.insert(clipped) }
        }
        for reservation in request.reservations {
            try Task.checkCancellation()
            guard reservation.rect.isFinite, !reservation.rect.isEmpty else { continue }
            let clipped = reservation.rect.intersection(request.viewport)
            if clipped.isFinite && !clipped.isEmpty { grid.insert(clipped, id: reservation.id) }
        }
        return grid
    }

    private func chooseStyle(for candidate: ProjectedPlace, in request: LayoutRequest, avoiding grid: CollisionGrid,
                             from zoomStyles: [MarkerStyle], allowsPhoto: Bool) -> MarkerStyle? {
        for style in eligibleStyles(for: candidate.place.id, request: request, zoomStyles: zoomStyles) {
            if style.hasPhoto && !allowsPhoto { continue }
            guard fitsViewport(candidate, style: style, in: request) else { continue }
            let rect = collisionBounds(for: candidate, style: style, in: request)
            if !grid.intersects(rect, ignoring: candidate.place.id) { return style }
        }
        return nil
    }

    /// During movement, retain or downgrade existing appearances; new places enter as dots.
    func eligibleStyles(for id: String, request: LayoutRequest, zoomStyles: [MarkerStyle]) -> ArraySlice<MarkerStyle> {
        let available = id == request.selectedID ? request.policy.styles(at: request.zoom, selected: true) : zoomStyles
        if request.isSettled { return available[...] }
        let maximumStyleDuringMovement = request.previous[id] ?? .dot
        let firstAllowedIndex = available.firstIndex {
            $0.rawValue <= maximumStyleDuringMovement.rawValue
        } ?? available.endIndex
        return available[firstAllowedIndex...]
    }

    func fitsViewport(_ candidate: ProjectedPlace, style: MarkerStyle, in request: LayoutRequest) -> Bool {
        let artwork = MarkerGeometry(style: style, scale: request.scale).visualBounds(at: candidate.point)
        guard !request.viewport.intersection(artwork).isEmpty else { return false }
        // A selected label must be fully readable; smaller appearances can overlap the edge.
        if candidate.place.id == request.selectedID, style.hasLabel {
            return request.viewport.contains(collisionBounds(for: candidate, style: style, in: request))
        }
        return true
    }

    private func collisionBounds(for candidate: ProjectedPlace, style: MarkerStyle, in request: LayoutRequest) -> CGRect {
        let rect = MarkerGeometry(style: style, scale: request.scale).bounds(at: candidate.point)
        let previous = request.previous[candidate.place.id]
        let clearance = request.policy.collisionClearance(for: style, previous: previous)
        return rect.insetBy(dx: -clearance, dy: -clearance)
    }
}

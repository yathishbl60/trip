#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import CoreGraphics

extension LayoutModel {
    func updateSelection(_ id: String?) {
        for marker in markers { marker.select(marker.id == id) }
    }

    /// Include hidden places beneath this artwork, and dots too close to distinguish by touch.
    func choices(for marker: MarkerModel) -> [Place] {
        guard let origin = candidates.first(where: { $0.place.id == marker.id })?.point else { return [] }
        let bounds = MarkerGeometry(style: marker.style, scale: marker.scale).bounds(at: origin)
        let visible = Set(markers.filter(\.hasAppeared).map(\.id))
        let radius = 24 * marker.scale
        return candidates.filter {
            let x = $0.point.x - origin.x, y = $0.point.y - origin.y
            return x * x + y * y <= radius * radius
                || (!visible.contains($0.place.id) && bounds.contains($0.point))
        }.map(\.place)
    }
}

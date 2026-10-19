#if os(iOS) || os(visionOS)
import TripDomain

extension DirectionsModel {
    /// A planned day starts at its first place; a single destination uses the normal origin picker.
    public func beginItinerary(_ places: [Place], origin: Coordinate?) {
        guard let first = places.first, let last = places.last,
              places.count <= min(20, max(0, configuration.maximumStops)) + 2,
              places.allSatisfy({ $0.coordinate.isValid }) else { return }
        guard places.count > 1 else { begin(first, origin: origin); return }
        destination = last
        startingPoint.reset()
        startingPoint.selection = .place(first)
        stops = Array(places.dropFirst().dropLast())
        presentation.reset()
        stopSearch.reset()
        refresh()
    }
}
#endif

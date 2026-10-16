import Foundation

/// Preserves fixed-arrival positions and the event slots in a mixed itinerary.
public nonisolated enum TripDayReordering {
    public static func move(_ offsets: IndexSet, to destination: Int, in day: inout TripDay) -> Bool {
        guard let edit = IdentifiedListEdit.moving(offsets, to: destination, in: day.stops.map(\.id)) else { return false }
        var proposed = day.stops
        guard edit.apply(to: &proposed), keepsFixedStops(day.stops, proposed) else { return false }
        day.stops = proposed
        synchronizeOrder(&day)
        return true
    }

    public static func synchronizeOrder(_ day: inout TripDay) {
        let ids = Set(day.stops.map(\.id))
        var iterator = day.stops.makeIterator()
        day.itemOrder = day.itemOrder.map { ids.contains($0) ? iterator.next()?.id ?? $0 : $0 }
        day.itemOrder.append(contentsOf: iterator.map(\.id))
    }

    private static func keepsFixedStops(_ original: [TripStop], _ proposed: [TripStop]) -> Bool {
        for (index, stop) in original.enumerated() where stop.timing.arrivalMinute != nil {
            guard proposed[index].id == stop.id,
                  Set(original[..<index].map(\.id)) == Set(proposed[..<index].map(\.id)) else { return false }
        }
        return true
    }
}

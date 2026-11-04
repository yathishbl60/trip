import Foundation

nonisolated extension TripStopTransfer {
    var affectedDays: Set<UUID> {
        Set(snapshot.days.filter { day in day.stops.contains { sourceIDs.contains($0.id) } }.map(\.id))
            .union([destinationDayID])
    }

    var movingStops: [TripStop]? {
        guard !sourceIDs.isEmpty, Set(sourceIDs).count == sourceIDs.count,
              snapshot.events.allSatisfy({ !sourceIDs.contains($0.id) }) else { return nil }
        let stops = snapshot.days.flatMap(\.stops).filter { sourceIDs.contains($0.id) }
        guard stops.count == sourceIDs.count, Set(stops.map(\.id)).count == stops.count,
              stops.allSatisfy({ $0.timing.arrivalMinute == nil }) else { return nil }
        let lookup = Dictionary(uniqueKeysWithValues: stops.map { ($0.id, $0) })
        return sourceIDs.compactMap { lookup[$0] }
    }

    func isCurrent(_ trip: TripPlan) -> Bool {
        guard trip.id == snapshot.id, trip.startDate == snapshot.startDate,
              trip.timeZoneID == snapshot.timeZoneID, trip.localStartDate == snapshot.localStartDate,
              trip.events == snapshot.events else { return false }
        return affectedDays.allSatisfy { id in
            guard let original = snapshot.days.first(where: { $0.id == id }),
                  let current = trip.days.first(where: { $0.id == id }) else { return false }
            return original == current
        }
    }

    func accepts(_ stops: [TripStop], in destination: TripDay) -> Bool {
        let remaining = destination.stops.filter { !sourceIDs.contains($0.id) }
        let proposed = remaining + stops
        return proposed.count <= TripLimits.stops
            && Set(proposed.map(\.place.id)).count == proposed.count
    }
}

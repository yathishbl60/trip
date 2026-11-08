import Foundation

extension TripPlan {
    /// Move the existing saved visit to the end of a day without changing its identity or timing.
    @discardableResult public mutating func moveVisit(_ stopID: UUID, to destinationDayID: UUID) throws -> Bool {
        let matches = days.flatMap(\.stops).filter { $0.id == stopID }
        guard matches.count == 1, !events.contains(where: { $0.id == stopID }),
              let source = days.firstIndex(where: { $0.stops.contains { $0.id == stopID } }),
              let stop = days[source].stops.first(where: { $0.id == stopID }) else {
            throw TripVisitMoveError.missingVisit
        }
        guard let destination = days.firstIndex(where: { $0.id == destinationDayID }) else {
            throw TripVisitMoveError.missingDay
        }
        guard source != destination else { return false }
        try validateVisitDestination(stop, in: days[destination])
        let destinationOrder = journeyItems(on: days[destination]).map(\.id)
        days[source].stops.removeAll { $0.id == stopID }
        days[source].itemOrder.removeAll { $0 == stopID }
        days[destination].stops.append(stop)
        days[destination].itemOrder = destinationOrder + [stopID]
        return true
    }

    private func validateVisitDestination(_ stop: TripStop, in day: TripDay) throws {
        switch TripStopAvailability(placeID: stop.place.id, stops: day.stops) {
        case .available: return
        case .alreadySaved: throw TripVisitMoveError.duplicate
        case .full: throw TripVisitMoveError.full
        }
    }
}

import Foundation

/// An identity-based drag, bound to the displayed days and their calendar context.
public nonisolated struct TripStopTransfer: Sendable {
    let sourceIDs: [UUID]
    let destinationDayID: UUID
    let beforeID: UUID?
    let snapshot: TripPlan

    public init(sourceIDs: [UUID], destinationDayID: UUID, beforeID: UUID?, snapshot: TripPlan) {
        self.sourceIDs = sourceIDs
        self.destinationDayID = destinationDayID
        self.beforeID = beforeID
        self.snapshot = snapshot
    }

    @discardableResult public func apply(to trip: inout TripPlan) -> Bool {
        guard let stops = movingStops, isCurrent(trip),
              let destination = trip.days.first(where: { $0.id == destinationDayID }),
              accepts(stops, in: destination) else { return false }
        var proposal = trip
        for index in proposal.days.indices where affectedDays.contains(proposal.days[index].id) {
            guard let day = reordered(proposal.days[index], in: trip, moving: stops) else { return false }
            proposal.days[index] = day
        }
        guard preservesFixedOrder(in: proposal) else { return false }
        trip = proposal
        return true
    }

    private func reordered(_ day: TripDay, in trip: TripPlan, moving stops: [TripStop]) -> TripDay? {
        var items = trip.journeyItems(on: day).filter { !sourceIDs.contains($0.id) }
        if day.id == destinationDayID {
            let slot = beforeID.flatMap { id in items.firstIndex { $0.id == id } } ?? items.count
            guard beforeID == nil || slot < items.count else { return nil }
            items.insert(contentsOf: stops.map(TripJourneyItem.visit), at: slot)
        }
        var updated = day
        updated.stops = items.compactMap(\.stop)
        updated.itemOrder = items.map(\.id)
        return updated
    }

    private func preservesFixedOrder(in proposal: TripPlan) -> Bool {
        guard affectedDays.count == 1, let original = snapshot.days.first(where: { $0.id == destinationDayID }),
              let updated = proposal.days.first(where: { $0.id == destinationDayID }) else { return true }
        for stop in original.stops where stop.timing.arrivalMinute != nil {
            let before = original.stops.prefix { $0.id != stop.id }.map(\.id)
            let after = updated.stops.prefix { $0.id != stop.id }.map(\.id)
            guard Set(before) == Set(after) else { return false }
        }
        return true
    }
}

import Foundation

extension TripPlan {
    /// Remove a day, trimming spans to their surviving days and keeping one event record.
    public mutating func removeJourneyDay(_ dayID: UUID) -> Bool {
        guard days.count > 1, days.contains(where: { $0.id == dayID }) else { return false }
        events = events.compactMap { event in
            guard let range = event.dayRange(in: self) else { return event }
            let remaining = days[range].filter { $0.id != dayID }
            guard let first = remaining.first, let last = remaining.last else { return nil }
            return trimmed(event, removing: dayID, first: first, last: last)
        }
        days.removeAll { $0.id == dayID }
        for index in days.indices { days[index].number = index + 1 }
        return true
    }

    private func trimmed(_ event: TripEvent, removing dayID: UUID, first: TripDay, last: TripDay) -> TripEvent {
        var updated = event
        if event.startDayID == dayID {
            updated.startMinute = nil
            updated.departureTime = nil
        }
        if event.endDayID == dayID {
            updated.endMinute = nil
            updated.arrivalTime = nil
        }
        updated.startDayID = first.id
        updated.endDayID = last.id
        return updated
    }

    public mutating func setJourneyOrder(_ items: [TripJourneyItem], dayID: UUID) -> Bool {
        guard let index = days.firstIndex(where: { $0.id == dayID }),
              Set(items.map(\.id)).count == items.count,
              Set(items.map(\.id)) == Set(journeyItems(on: days[index]).map(\.id)) else { return false }
        days[index].itemOrder = items.map(\.id)
        days[index].stops = items.compactMap(\.stop)
        return true
    }

    public func preservesEventSpans(from original: TripPlan) -> Bool {
        events.allSatisfy { event in
            guard let previous = event.dayRange(in: original), let current = event.dayRange(in: self) else { return false }
            return Set(original.days[previous].map(\.id)) == Set(days[current].map(\.id))
        }
    }
}

#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

public nonisolated enum TripJourneyItem: Identifiable, Equatable, Sendable {
    case visit(TripStop)
    case event(TripEvent)

    public var id: UUID {
        switch self {
        case .visit(let stop): stop.id
        case .event(let event): event.id
        }
    }

    public var stop: TripStop? {
        if case .visit(let stop) = self { return stop }
        return nil
    }
}

extension TripPlan {
    /// Preserve event placement while honoring place order changed by other workflows.
    public nonisolated func journeyItems(on day: TripDay) -> [TripJourneyItem] {
        let eventItems = events.filter { $0.occurs(on: day.id, in: self) }.map(TripJourneyItem.event)
        let lookup = Dictionary(eventItems.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let stopIDs = Set(day.stops.map(\.id))
        var stops = day.stops.makeIterator()
        var used = Set<UUID>()
        let ordered: [TripJourneyItem] = day.itemOrder.compactMap { id in
            guard used.insert(id).inserted else { return nil }
            if stopIDs.contains(id) { return stops.next().map(TripJourneyItem.visit) }
            return lookup[id]
        }
        let remaining = day.stops.dropFirst(ordered.compactMap(\.stop).count).map(TripJourneyItem.visit)
        return ordered + remaining + eventItems.filter { !used.contains($0.id) }
    }

    public nonisolated func journeySummary(on day: TripDay) -> String {
        let count = events.count { $0.occurs(on: day.id, in: self) }
        guard count > 0 else { return day.placeCountText }
        let eventText = TripText.eventCount(count).text
        return day.stops.isEmpty ? eventText : "\(day.placeCountText) · \(eventText)"
    }
}

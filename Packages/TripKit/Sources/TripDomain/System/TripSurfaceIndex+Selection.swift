import Foundation

public nonisolated enum TripSurfacePurpose: Equatable, Sendable { case itinerary, departure }

extension TripSurfaceIndex {
    public nonisolated func selectedTripID(for purpose: TripSurfacePurpose, journey: TripJourney?, at date: Date) -> UUID? {
        if purpose == .departure {
            return trips.first { $0.startDate >= $0.calendar.startOfDay(for: date) }?.id
        }
        if let journey, journey.isActive, journey.expiresAt > date,
           trips.contains(where: { $0.id == journey.tripID }) { return journey.tripID }
        return trips.first { $0.endDate >= $0.calendar.startOfDay(for: date) }?.id
    }

    public nonisolated func nextMidnight(after date: Date) -> Date? {
        trips.compactMap { trip in
            trip.calendar.date(byAdding: .day, value: 1, to: trip.calendar.startOfDay(for: date))
        }.min()
    }
}

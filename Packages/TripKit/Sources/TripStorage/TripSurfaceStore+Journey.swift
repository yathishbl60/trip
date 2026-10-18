import TripDomain
import Foundation

extension TripSurfaceStore {
    public func advance(expectedStopID: UUID? = nil, tripID: UUID? = nil, dayID: UUID? = nil) throws -> TripJourney {
        let (stored, day) = try activeDay()
        var journey = stored
        guard tripID == nil || tripID == journey.tripID, dayID == nil || dayID == journey.dayID else { return journey }
        if let expectedStopID, journey.visited.contains(expectedStopID) { return journey }
        journey.reconcile(with: day)
        guard journey.isActive, Date.now < journey.expiresAt else { throw TripSurfaceError.noJourney }
        guard let next = journey.nextStop(in: day) else { throw TripSurfaceError.finishedDay }
        guard expectedStopID == nil || expectedStopID == next.id else { return journey }
        journey.visited.append(next.id)
        journey.reconcile(with: day)
        try saveJourney(journey)
        return journey
    }

    public func undoVisit() throws -> TripJourney {
        let (stored, day) = try activeDay()
        var journey = stored
        guard Date.now < journey.expiresAt else { throw TripSurfaceError.noJourney }
        guard !journey.visited.isEmpty else { return journey }
        journey.visited.removeLast()
        journey.isActive = true
        journey.reconcile(with: day)
        try saveJourney(journey)
        return journey
    }

    public func endJourney() throws -> TripJourney {
        guard var journey = try journey() else { throw TripSurfaceError.noJourney }
        journey.isActive = false
        try saveJourney(journey)
        return journey
    }

    private func activeDay() throws -> (TripJourney, TripSurfaceDay) {
        guard let journey = try journey() else { throw TripSurfaceError.noJourney }
        guard let plan = try plan(journey.tripID) else { throw TripSurfaceError.missingTrip }
        guard let day = plan.days.first(where: { $0.id == journey.dayID }) else { throw TripSurfaceError.missingDay }
        return (journey, day)
    }
}

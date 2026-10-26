import TripLocalization
import Foundation
import TripDomain

extension AppRuntime {
    static func nextStep(tripID: UUID? = nil) async throws -> TripNextStep {
        let library = try await library()
        let journey = try await TripSystemData.journey()
        let now = Date.now
        let plan: TripPlan
        if let tripID {
            guard let saved = library.trip(tripID) else { throw TripIntentError.missingTrip }
            plan = saved
        } else {
            plan = try currentTrip(in: library.trips, journey: journey, at: now)
        }
        return TripNextStep(plan: TripSurfacePlan(plan), journey: journey, at: now)
    }

    static func openNextStep(tripID: UUID) async throws {
        let next = try await nextStep(tripID: tripID)
        guard activeScene?.trips.hasEditingSession != true else { throw TripDetailIntentError.editing }
        if let item = next.item {
            try await openDetail(TripDetailIdentity(tripID: tripID, itemID: item.id))
        } else { openTrip(tripID) }
    }

    private static func currentTrip(in trips: [TripPlan], journey: TripJourney?, at now: Date) throws -> TripPlan {
        if let journey, journey.isActive, journey.expiresAt > now,
           let trip = trips.first(where: { $0.id == journey.tripID }),
           trip.days.contains(where: { $0.id == journey.dayID }) { return trip }
        let today = trips.filter { trip in
            trip.days.contains { trip.calendar.isDate(trip.date(for: $0), inSameDayAs: now) }
        }
        guard today.count == 1, let trip = today.first else {
            throw today.isEmpty ? TripNextStepError.noCurrentTrip : TripNextStepError.multipleTrips
        }
        return trip
    }
}

nonisolated enum TripNextStepError: LocalizedError {
    case noCurrentTrip, multipleTrips
    var errorDescription: String? {
        switch self {
        case .noCurrentTrip: TripText.noTripIsPlannedForTodayChooseATrip.text
        case .multipleTrips: TripText.moreThanOneTripIsPlannedForTodayChoose.text
        }
    }
}

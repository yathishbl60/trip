import TripDomain
import Foundation

extension AppRuntime {
    static func createTrip(name: String, departure: Date, days: Int) async throws -> SavedTripEntity {
        let title = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...TripLimits.titleCharacters).contains(title.count) else { throw TripIntentError.invalidTitle }
        let session = try await library()
        try Task.checkCancellation()
        guard activeScene?.trips.hasEditingSession != true else { throw TripDetailIntentError.editing }
        var plan = TripPlan(title: title)
        plan.startDate = Calendar.current.startOfDay(for: departure)
        plan.days = (1...min(max(days, 1), TripLimits.days)).map { TripDay(number: $0) }
        guard session.insert(plan) else { throw TripIntentError.tooManyTrips }
        await session.flush()
        guard session.saveError == nil else { throw TripIntentError.saveFailed }
        return SavedTripEntity(TripSurfaceSummary(TripSurfacePlan(plan)))
    }

    static func startDay(tripID: UUID, number: Int) async throws {
        let plan = try await trip(tripID)
        guard let day = plan.days.first(where: { $0.number == number }) else { throw TripIntentError.missingDay }
        await savedTrips.flush()
        guard savedTrips.saveError == nil else { throw TripIntentError.saveFailed }
        try await TripJourneyRuntime.shared.start(tripID: plan.id, dayID: day.id)
        openTrip(plan.id)
    }
}

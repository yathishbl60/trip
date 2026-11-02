import TripLocalization
import TripDomain
import TripStorage
import Foundation

nonisolated enum TripWidgetReader {
    static func entry(tripID: UUID?, at date: Date) async -> TripWidgetEntry {
        do {
            let index = try await TripSystemData.store.index()
            let journey = try await TripSystemData.store.journey()
            let id = tripID ?? selectedID(index: index, journey: journey, at: date)
            guard let id, let plan = try await TripSystemData.store.plan(id) else {
                return TripWidgetEntry(date: date, notice: tripID == nil
                    ? TripText.saveATripToSeeYourItineraryHere.text : TripText.thisTripIsNoLongerAvailable.text)
            }
            return entry(plan: plan, journey: journey, at: date)
        } catch {
            return TripWidgetEntry(date: date, notice: TripText.openTripToRefreshYourItinerary.text)
        }
    }

    private static func selectedID(index: TripSurfaceIndex?, journey: TripJourney?, at date: Date) -> UUID? {
        if let journey, journey.isActive, journey.expiresAt > date,
           index?.trips.contains(where: { $0.id == journey.tripID }) == true { return journey.tripID }
        return index?.trips.first { $0.endDate >= $0.calendar.startOfDay(for: date) }?.id
    }

    private static func entry(plan: TripSurfacePlan, journey: TripJourney?, at date: Date) -> TripWidgetEntry {
        let selection = TripSurfaceSelection(plan: plan, journey: journey, at: date)
        return TripWidgetEntry(date: date, plan: plan, day: selection.day, journey: selection.journey)
    }
}

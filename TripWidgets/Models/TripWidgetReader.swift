import TripLocalization
import TripDomain
import TripStorage
import Foundation

nonisolated struct TripWidgetReader {
    let index: TripSurfaceIndex?
    let journey: TripJourney?
    private(set) var needsRetry = false
    private var plans: [UUID: TripSurfacePlan] = [:]

    init() async throws {
        index = try await TripSystemData.store.index()
        journey = try await TripSystemData.store.journey()
    }

    static func entry(tripID: UUID?, at date: Date, purpose: TripSurfacePurpose = .itinerary) async -> TripWidgetEntry {
        do {
            var reader = try await Self()
            return await reader.entry(tripID: tripID, at: date, purpose: purpose)
        } catch { return TripWidgetEntry(date: date, notice: TripText.openTripToRefreshYourItinerary.text) }
    }

    mutating func entry(tripID: UUID?, at date: Date, purpose: TripSurfacePurpose) async -> TripWidgetEntry {
        do {
            let id = tripID ?? index?.selectedTripID(for: purpose, journey: journey, at: date)
            guard let id, let plan = try await plan(id) else {
                let notice = purpose == .departure ? TripText.noUpcomingDeparture.text : TripText.saveATripToSeeYourItineraryHere.text
                return TripWidgetEntry(date: date, notice: tripID == nil
                    ? notice : TripText.thisTripIsNoLongerAvailable.text)
            }
            let selection = TripSurfaceSelection(plan: plan, journey: journey, at: date)
            return TripWidgetEntry(date: date, plan: plan, day: selection.day, journey: selection.journey)
        } catch {
            needsRetry = true
            return TripWidgetEntry(date: date, notice: TripText.openTripToRefreshYourItinerary.text)
        }
    }

    private mutating func plan(_ id: UUID) async throws -> TripSurfacePlan? {
        if let cached = plans[id] { return cached }
        let plan = try await TripSystemData.store.plan(id)
        plans[id] = plan
        return plan
    }
}

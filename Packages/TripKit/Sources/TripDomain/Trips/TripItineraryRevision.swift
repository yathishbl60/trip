#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

/// A reviewed replacement, bound to the itinerary used to generate it.
public nonisolated struct TripItineraryRevision: Sendable {
    private let tripID: UUID
    private let originalDays: [TripDay]
    private let startDate: Date
    private let zoneID: String?

    public init(_ trip: TripPlan) {
        tripID = trip.id
        originalDays = trip.days
        startDate = trip.startDate
        zoneID = trip.timeZoneID
    }

    public func issue(in trip: TripPlan, draft: [TripDay]) -> String? {
        guard trip.id == tripID, trip.days == originalDays, trip.startDate == startDate, trip.timeZoneID == zoneID else {
            return TripText.yourItineraryChangedCreateANewDraftBeforeApplying.text
        }
        guard !draft.isEmpty, draft.count <= TripLimits.days,
              draft.allSatisfy({ $0.stops.count <= TripLimits.stops }) else { return TripText.createADraftFirst.text }
        return protectedContentIssue(draft, trip: trip) ?? retentionIssue(draft, trip: trip)
    }

    private func protectedContentIssue(_ draft: [TripDay], trip: TripPlan) -> String? {
        if !trip.events.isEmpty { return TripText.thisTripHasJourneyEventsSaveANewTrip.text }
        if originalDays.contains(where: { $0.schedule != nil || $0.stops.contains { $0.timing.arrivalMinute != nil } }) {
            return TripText.thisTripHasPlannedTimesSaveANewTrip.text
        }
        if originalDays.dropFirst(draft.count).contains(where: { !$0.notes.isEmpty }) {
            return TripText.useMoreDaysOrSaveANewTripTo.text
        }
        return nil
    }

    private func retentionIssue(_ draft: [TripDay], trip: TripPlan) -> String? {
        let existing = originalDays.flatMap(\.stops).map(\.place.id)
        let proposed = draft.flatMap(\.stops).map(\.place.id)
        guard Set(proposed).isSubset(of: Set(trip.savedPlaces.map(\.id))) else {
            return TripText.theDraftIncludesPlacesThatAreNoLongerSaved.text
        }
        guard Set(proposed).count == proposed.count else { return TripText.theDraftRepeatsAPlaceCreateANewDraft.text }
        guard Set(existing).count == existing.count else {
            return TripText.thisTripIncludesRepeatVisitsSaveANewTrip.text
        }
        guard Set(existing).isSubset(of: Set(proposed)) else {
            return TripText.selectEveryPlannedPlaceToUpdateThisTripOr.text
        }
        return nil
    }

    @discardableResult public func apply(_ draft: [TripDay], to trip: inout TripPlan) -> Bool {
        guard issue(in: trip, draft: draft) == nil else { return false }
        let originals = Dictionary(originalDays.flatMap(\.stops).map { ($0.place.id, $0) },
                                   uniquingKeysWith: { first, _ in first })
        trip.days = draft.enumerated().map { index, day in
            var updated = originalDays.indices.contains(index) ? originalDays[index] : day
            updated.number = index + 1
            if updated.notes.isEmpty { updated.notes = day.notes }
            updated.stops = day.stops.map { originals[$0.place.id] ?? $0 }
            return updated
        }
        return true
    }
}

import TripLocalization
import Foundation
import TripDomain

extension TripModel {
    func beginEvent(dayID: UUID, tripID: UUID, eventID: UUID? = nil, kind: TripEventKind = .activity) {
        guard let trip = library.trip(tripID), trip.days.contains(where: { $0.id == dayID }) else { return }
        guard eventID != nil || trip.events.count < TripLimits.events else { return }
        let event = trip.events.first { $0.id == eventID }
        guard eventID == nil || event != nil else { return }
        presentation.eventDraft = TripEventDraft(trip: trip, dayID: dayID, event: event, kind: kind)
    }

    func beginNewEvent(_ request: TripNewEventRequest) throws {
        guard !hasEditingSession else { return }
        guard let trip = library.trip(request.tripID) else { throw TripNewEventError.missingTrip }
        try request.validate(in: trip)
        beginEvent(dayID: request.dayID, tripID: trip.id, kind: request.kind)
        if !request.title.isEmpty { presentation.eventDraft?.event.title = request.title }
    }

    func saveEvent(_ draft: TripEventDraft) {
        guard presentation.eventDraft?.id == draft.id else { return }
        guard library.update(draft.tripID, edit: { draft.save(in: &$0) }) else {
            if draft.error == nil { draft.error = TripText.thisTripIsNoLongerAvailable.text }
            return
        }
        presentation.eventDraft = nil
        feedback.show(draft.original == nil ? TripText.eventAdded.text : TripText.eventUpdated.text)
    }

    func deleteEvent(_ draft: TripEventDraft) {
        guard presentation.eventDraft?.id == draft.id, let original = draft.original else { return }
        let removed = library.update(draft.tripID) { trip in
            guard trip.events.first(where: { $0.id == original.id }) == original else { return false }
            trip.events.removeAll { $0.id == original.id }
            for index in trip.days.indices { trip.days[index].itemOrder.removeAll { $0 == original.id } }
            return true
        }
        if removed { presentation.eventDraft = nil; feedback.show(TripText.eventRemoved.text) }
        else { draft.error = TripText.thisEventChangedOrWasRemovedElsewhereCancelAnd.text }
    }

    func moveJourneyItems(_ offsets: IndexSet, to destination: Int, day: TripDay, trip: TripPlan) {
        let snapshot = trip.journeyItems(on: day)
        guard !tracking.isBusy,
              let edit = IdentifiedListEdit.moving(offsets, to: destination, in: snapshot.map(\.id)) else { return }
        library.update(trip.id) { current in
            guard let currentDay = current.days.first(where: { $0.id == day.id }) else { return false }
            var items = current.journeyItems(on: currentDay)
            guard items.map(\.id) == snapshot.map(\.id), edit.apply(to: &items) else { return false }
            return current.setJourneyOrder(items, dayID: day.id)
        }
    }

    func removeJourneyVisits(_ offsets: IndexSet, day: TripDay, trip: TripPlan) {
        let items = trip.journeyItems(on: day)
        guard offsets.allSatisfy(items.indices.contains) else { return }
        let ids = Set(offsets.compactMap { items[$0].stop?.id })
        let stops = IndexSet(day.stops.indices.filter { ids.contains(day.stops[$0].id) })
        removeStops(stops, from: day, tripID: trip.id)
    }
}

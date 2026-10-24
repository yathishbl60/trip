#if DEBUG
import Foundation
import TripDomain

enum TripJourneyPreview {
    static func planner() -> TripModel {
        PreviewTripServices.makeTrips([plan()])
    }

    static func draft(in model: TripModel, eventIndex: Int? = nil, kind: TripEventKind = .activity) -> TripEventDraft {
        let trip = model.library.trips[0]
        let event = eventIndex.map { trip.events[$0] }
        let draft = TripEventDraft(trip: trip, dayID: trip.days[0].id, event: event, kind: kind)
        model.presentation.eventDraft = draft
        return draft
    }

    static func plan() -> TripPlan {
        var trip = TripPlan(title: "A long weekend in Bangkok")
        trip.startDate = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 16)) ?? .distantPast
        trip.days = (1...4).map { TripDay(number: $0) }
        trip.days[0].stops = [TripStop(place: PreviewFixtures.unrated)]
        trip.events = events(in: trip)
        trip.days[0].itemOrder = [trip.events[0].id, trip.events[1].id, trip.days[0].stops[0].id, trip.events[2].id]
        return trip
    }

    private static func events(in trip: TripPlan) -> [TripEvent] {
        var flight = TripEvent(kind: .flight, title: "Flight to Bangkok", dayID: trip.days[0].id)
        flight.startMinute = 480
        flight.endMinute = 600
        flight.location = "Chiang Mai · CNX"
        flight.arrivalLocation = "Bangkok · BKK"
        var stay = TripEvent(kind: .stay, title: "Riverside hotel", dayID: trip.days[0].id)
        stay.endDayID = trip.days[3].id
        stay.startMinute = 900
        stay.endMinute = 660
        stay.notes = "Ask about luggage storage before check-in."
        let walk = TripEvent(kind: .activity, title: "An unhurried walk along the river", dayID: trip.days[0].id)
        let freeTime = TripEvent(kind: .freeTime, title: "Leave the afternoon open", dayID: trip.days[1].id)
        return [flight, stay, walk, freeTime]
    }
}
#endif

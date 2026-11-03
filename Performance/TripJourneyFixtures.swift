import Foundation

enum TripJourneyFixtures {
    static func plan() -> TripPlan {
        var trip = TripPlan(title: "Complete journey")
        trip.days = (1...4).map { TripDay(number: $0) }
        trip.days[0].stops = [TripStop(place: CheckFixtures.place("journey-place"))]
        var flight = TripEvent(kind: .flight, title: "Flight", dayID: trip.days[0].id)
        flight.startMinute = 480
        flight.endMinute = 600
        var stay = TripEvent(kind: .stay, title: "Three nights", dayID: trip.days[0].id)
        stay.endDayID = trip.days[3].id
        stay.startMinute = 900
        stay.endMinute = 660
        let walk = TripEvent(kind: .activity, title: "Untimed walk", dayID: trip.days[0].id)
        trip.events = [flight, stay, walk]
        trip.days[0].itemOrder = [flight.id, trip.days[0].stops[0].id, stay.id, walk.id]
        return trip
    }
}

import Foundation

enum TripInsertionChecks {
    static func run() throws {
        try betweenNeighbors()
        try invalidCoordinates()
        try dateLine()
    }

    private static func betweenNeighbors() throws {
        var day = TripDay(number: 1)
        day.stops = [100.49, 100.51].enumerated().map {
            TripStop(place: CheckFixtures.place("neighbor-\($0.offset)", longitude: $0.element))
        }
        let place = CheckFixtures.place("insert", longitude: 100.5)
        let choice = TripPlaceInsertion.best(for: place, in: day)
        try require(choice?.index == 1 && choice?.nearbyName != nil, "Did not insert between nearby visits")
        try require(choice?.distance?.isFinite == true, "Insertion produced a nonfinite score")
        var trip = TripPlan(title: "Nearby")
        let empty = TripDay(number: 2)
        trip.days = [empty, day]
        try require(TripPlaceInsertion.suggestions(for: place, in: trip).first?.dayID == day.id,
                    "Empty day outranked geographic evidence")
    }

    private static func invalidCoordinates() throws {
        var day = TripScheduleFixtures.day()
        let invalid = CheckFixtures.place("invalid", longitude: .nan)
        let choice = TripPlaceInsertion.best(for: invalid, in: day)
        try require(choice?.index == day.stops.count && choice?.distance == nil, "Invented a ranking for invalid coordinates")
        day.stops = [TripStop(place: invalid)]
        let valid = TripPlaceInsertion.best(for: CheckFixtures.place("valid"), in: day)
        try require(valid?.nearbyName == nil && valid?.distance == nil, "Invalid neighbor influenced a recommendation")
    }

    private static func dateLine() throws {
        var day = TripDay(number: 1)
        day.stops = [TripStop(place: CheckFixtures.place("east", longitude: 179.99))]
        let west = CheckFixtures.place("west", longitude: -179.99)
        let choice = TripPlaceInsertion.best(for: west, in: day)
        try require((choice?.distance ?? .infinity) < 3_000, "Insertion went around the world at the date line")
        try require(choice?.nearbyName != nil, "Date-line neighbor disappeared")
        let distant = TripPlaceInsertion.best(for: CheckFixtures.place("far", longitude: 0), in: day)
        try require(distant?.nearbyName == nil, "Called a distant stop nearby")
    }
}

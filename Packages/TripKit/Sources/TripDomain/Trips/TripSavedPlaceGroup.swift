import Foundation

public nonisolated struct TripSavedPlaceGroup: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let places: [Place]
    public let previousStops: [TripPreviousStop]

    public init(_ plan: TripPlan) {
        id = plan.id
        title = plan.title
        places = plan.savedPlaces
        previousStops = plan.days.flatMap { day in
            zip(day.stops, day.stops.dropFirst()).map {
                TripPreviousStop(id: $1.id, destinationID: $1.place.id, place: $0.place, dayTitle: day.title)
            }
        }
    }
}

public nonisolated struct TripPreviousStop: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let destinationID: String
    public let place: Place
    public let dayTitle: String
}

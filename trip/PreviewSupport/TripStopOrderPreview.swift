import TripDomain

#if DEBUG
@MainActor enum TripStopOrderPreview {
    static func fixture() -> (TripModel, TripStopOrderModel) {
        var trip = TripPlan(title: "Sample city afternoon")
        trip.days[0].stops = [stop("Start", longitude: 100.55), stop("Museum", longitude: 100.59),
                              stop("Cafe", longitude: 100.56)]
        let day = trip.days[0]
        let suggested = [day.stops[0], day.stops[2], day.stops[1]]
        let proposal = TripStopOrderProposal(day: day, suggestedIDs: suggested.map(\.id),
            originalDistance: distance(day.stops), suggestedDistance: distance(suggested))
        let draft = TripStopOrderModel(tripID: trip.id, day: day, service: PreviewStopOrderService(), proposal: proposal)
        let model = PreviewTripServices.makeTrips([trip])
        model.presentation.stopOrder = draft
        return (model, draft)
    }

    private static func stop(_ name: String, longitude: Double) -> TripStop {
        TripStop(place: Place(id: "sample-\(name)", name: "Sample \(name)",
            coordinate: Coordinate(latitude: 13.75, longitude: longitude), category: .place,
            importance: 1, rating: nil, reviews: nil))
    }

    private static func distance(_ stops: [TripStop]) -> Double {
        zip(stops, stops.dropFirst()).reduce(0) { $0 + $1.0.place.coordinate.distance(to: $1.1.place.coordinate) }
    }
}
#endif

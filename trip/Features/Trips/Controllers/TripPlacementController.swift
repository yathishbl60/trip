import TripDomain

struct TripPlacementController {
    let model: TripPlacementModel

    func load(_ place: Place, in trip: TripPlan) async { await model.load(place, in: trip) }
    func cancel() { model.cancel() }
}

#if DEBUG
import Foundation
import TripDomain

@MainActor enum TripMapPreview {
    static func planner(missingLocations: Bool = false) -> TripModel {
        var trip = TripPlan(title: "Map review")
        _ = trip.reviewTimeZone("Asia/Bangkok", departure: TripLocalDate(year: 2026, month: 10, day: 22))
        trip.days[0].stops = (0..<12).map { TripStop(place: place($0, located: !missingLocations)) }
        trip.days.append(TripDay(number: 2))
        return PreviewTripServices.makeTrips([trip], environment: .init(showDirections: { _ in }))
    }

    static func map(_ planner: TripModel, selecting index: Int? = nil) -> TripMapModel {
        let model = TripMapModel(tripID: planner.library.trips[0].id, initialDayID: nil, library: planner.library)
        model.reconcile()
        if let index, model.stops.indices.contains(index) {
            model.selectStop(model.stops[index].id, focus: false, animated: false)
        }
        return model
    }

    private static func place(_ index: Int, located: Bool) -> Place {
        let coordinate = located ? Coordinate(latitude: 13.7478 + Double(index / 4) * 0.003,
            longitude: 100.5514 + Double(index % 4) * 0.003) : Coordinate(latitude: 91, longitude: 0)
        let name = index == 9 ? "Sample riverside museum and garden with a long place name" : "Sample place \(index + 1)"
        return Place(id: "map-preview-\(index)", name: name, coordinate: coordinate, category: .museum,
                     importance: 0.5, rating: nil, reviews: nil, address: "Local preview data")
    }
}
#endif

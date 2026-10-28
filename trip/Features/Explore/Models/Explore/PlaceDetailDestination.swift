import TripDomain

nonisolated enum PlaceDetailDestination: Hashable {
    case nearby([Place])
    case search(Place)
    case detail(Place)

    var detailPlace: Place? {
        guard case .detail(let place) = self else { return nil }
        return place
    }
}

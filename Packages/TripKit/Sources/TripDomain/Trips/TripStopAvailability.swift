/// One admission policy shared by save controls and mutation workflows.
public nonisolated enum TripStopAvailability: Equatable, Sendable {
    case available, alreadySaved, full

    public init(placeID: String, stops: [TripStop]) {
        if stops.contains(where: { $0.place.id == placeID }) { self = .alreadySaved }
        else if stops.count >= TripLimits.stops { self = .full }
        else { self = .available }
    }
}

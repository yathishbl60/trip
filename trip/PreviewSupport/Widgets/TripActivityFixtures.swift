#if DEBUG && TRIP_WIDGET_EXTENSION && os(iOS)
import Foundation
import TripDomain

nonisolated enum TripActivityFixtures {
    static let tripID = UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!
    static let dayID = UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")!
    static let stopID = UUID(uuidString: "EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE")!
    static var attributes: TripActivityAttributes {
        TripActivityAttributes(tripID: tripID, dayID: dayID, tripTitle: "Weekend in Bangkok", dayNumber: 1)
    }
    static var active: TripActivityAttributes.ContentState {
        TripActivityAttributes.ContentState(nextStopID: stopID, nextStopName: "Lumphini Park",
                                            visited: 1, total: 3, isActive: true, nextSymbol: "leaf.fill",
                                            plannedTime: Date(timeIntervalSince1970: 1_791_331_200),
                                            followingStopName: "Bangkok Art and Culture Centre", nextCoordinate: .bangkok)
    }
    static var completed: TripActivityAttributes.ContentState {
        TripActivityAttributes.ContentState(nextStopID: nil, nextStopName: "Day complete",
                                            visited: 3, total: 3, isActive: false)
    }
    static var longName: TripActivityAttributes.ContentState {
        TripActivityAttributes.ContentState(nextStopID: stopID,
            nextStopName: "Bangkok Art and Culture Centre and sculpture garden", visited: 9, total: 12,
            isActive: true, nextSymbol: "building.columns", followingStopName: "Lumphini Park", nextCoordinate: .bangkok)
    }
}
#endif

import TripLocalization
#if os(iOS)
import ActivityKit
import TripDomain
import Foundation

nonisolated struct TripActivityAttributes: ActivityAttributes {
    let tripID: UUID
    let dayID: UUID
    let tripTitle: String
    let dayNumber: Int

    nonisolated struct ContentState: Codable, Hashable, Sendable {
        let nextStopID: UUID?
        let nextStopName: String
        let visited: Int
        let total: Int
        let isActive: Bool
        var nextSymbol: String? = nil
        var plannedTime: Date? = nil
        var followingStopName: String? = nil
        var currentTripTitle: String? = nil
        var currentDayNumber: Int? = nil
        var timeZoneID: String? = nil
        var nextCoordinate: Coordinate? = nil
    }
}

extension TripActivityAttributes.ContentState {
    nonisolated init(journey: TripJourney, day: TripSurfaceDay, title: String? = nil) {
        let next = journey.nextStop(in: day)
        nextStopID = next?.id
        nextStopName = next?.name ?? TripText.dayComplete.text
        visited = journey.visited.count
        total = day.stops.count
        isActive = journey.isActive
        nextSymbol = next?.category.symbol
        let item = day.agenda.first { $0.id == next?.id }
        plannedTime = item?.requiresTimeReview == true ? nil : item?.startsAt
        followingStopName = day.stops.filter { !journey.visited.contains($0.id) }.dropFirst().first?.name
        currentTripTitle = title
        currentDayNumber = day.number
        timeZoneID = day.zoneID
        nextCoordinate = next?.coordinate
    }
}
#endif

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

    /// Bound encoded text, including emoji sequences and JSON escapes, within ActivityKit's payload budget.
    nonisolated static func boundedText(_ value: String) -> String {
        var result = ""
        let encoder = JSONEncoder()
        for character in value.prefix(96) {
            guard String(character).utf8.count <= 384 else { break }
            let next = result + String(character)
            guard let data = try? encoder.encode(next), data.count <= 384 else { break }
            result = next
        }
        return result.isEmpty && !value.isEmpty ? "…" : result
    }

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
        nextStopName = TripActivityAttributes.boundedText(next?.name ?? TripText.dayComplete.text)
        visited = journey.visited.count
        total = day.stops.count
        isActive = journey.isActive
        nextSymbol = next?.category.symbol
        let item = day.agenda.first { $0.id == next?.id }
        plannedTime = item?.requiresTimeReview == true ? nil : item?.startsAt
        let following = day.stops.lazy.filter { !journey.visited.contains($0.id) }.dropFirst().first?.name
        followingStopName = following.map(TripActivityAttributes.boundedText)
        currentTripTitle = title.map(TripActivityAttributes.boundedText)
        currentDayNumber = day.number
        timeZoneID = day.calendar.timeZone.identifier
        nextCoordinate = next.flatMap { $0.coordinate.isValid ? $0.coordinate : nil }
    }
}
#endif

import TripLocalization
import TripDomain
import Foundation

extension TripPlan {
    var dateSummary: String {
        let departure = startDate.formatted(Date.FormatStyle(timeZone: calendar.timeZone).month(.abbreviated).day())
        guard days.count > 1, let lastDay = days.last else { return departure }
        let returnDate = date(for: lastDay).formatted(Date.FormatStyle(timeZone: calendar.timeZone).month(.abbreviated).day())
        return "\(departure) – \(returnDate)"
    }

    var dayCountText: String { TripText.dayCount(days.count).text }
    var savedPlaceCountText: String { TripText.savedPlaceCount(savedPlaces.count).text }
    var eventCountText: String { TripText.eventCount(events.count).text }

    var overviewStatistics: String {
        let places = "\(dayCountText) · \(savedPlaceCountText)"
        return events.isEmpty ? places : "\(places) · \(eventCountText)"
    }

    var hasMappedPlaces: Bool {
        days.contains { $0.stops.contains { $0.place.coordinate.isValid } }
    }

    var coverCategory: PlaceCategory? { savedPlaces.first?.category }

    var shareText: String {
        let itinerary = days.map { $0.sharedSummary(in: self) }.joined(separator: "\n\n")
        return "\(title)\n\(dateSummary) · \(dayCountText)\n\n\(itinerary)"
    }
}

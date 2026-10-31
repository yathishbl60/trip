import TripLocalization
import Foundation
import TripDomain

struct TripEventPresentation {
    let event: TripEvent
    let day: TripDay
    let trip: TripPlan

    var spanText: String {
        guard let range = event.dayRange(in: trip) else { return event.kind.title }
        let distance = range.upperBound - range.lowerBound
        guard distance > 0 else { return event.kind.title }
        let span = event.kind == .stay ? TripText.nightCount(distance).text : TripText.dayCount(distance + 1).text
        return TripText.valueValueDayValueValue(event.kind.title, span, TripText.number(range.lowerBound + 1), TripText.number(range.upperBound + 1)).text
    }

    var timeText: String {
        var labels: [String] = []
        let spansDays = event.startDayID != event.endDayID
        if day.id == event.startDayID, event.startMinute != nil || spansDays {
            labels.append(boundary(event.startMinute, label: event.kind.startLabel))
        }
        if day.id == event.endDayID, event.endMinute != nil || spansDays {
            labels.append(boundary(event.endMinute, label: event.kind.endLabel))
        }
        if labels.isEmpty { return spansDays ? (event.kind == .stay ? TripText.stayingHere.text : TripText.continuesToday.text) : TripText.flexibleTime.text }
        return labels.joined(separator: " · ")
    }

    var showsTime: Bool {
        event.startMinute != nil || event.endMinute != nil || event.startDayID != event.endDayID
    }

    var accessibilityHint: String {
        event.startDayID == event.endDayID ? TripText.editEventDetails.text : TripText.editThisEventAcrossAllItsDays.text
    }

    var locationText: String {
        let locations = event.kind.isTransport ? [event.location, event.arrivalLocation] : [event.location]
        return locations.filter { !$0.isEmpty }.joined(separator: " → ")
    }

    var sharingText: String {
        [event.title, spanText, timeText, locationText].filter { !$0.isEmpty }.joined(separator: "\n")
    }

    private func boundary(_ minute: Int?, label: String) -> String {
        let clock = label == event.kind.startLabel ? event.departureTime : event.arrivalTime
        if let clock { return "\(label) \(clock.description)" }
        guard let minute else { return TripText.valueTimeNotSet(label).text }
        if trip.needsTimeZoneReview { return TripText.valueReviewTimeZone(label).text }
        let date = TripScheduleClock.date(minute: minute, on: trip.date(for: day), calendar: trip.calendar)
        let text = date.formatted(Date.FormatStyle(date: .omitted, time: .shortened, timeZone: trip.calendar.timeZone))
        return "\(label) \(text) · \(trip.calendar.timeZone.identifier)"
    }
}

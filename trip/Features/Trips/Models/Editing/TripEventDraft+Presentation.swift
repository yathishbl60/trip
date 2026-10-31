import TripLocalization
import Foundation
import TripDomain

extension TripEventDraft {
    var titlePrompt: String {
        switch event.kind {
        case .flight: TripText.flightNameOrNumber.text
        case .train: TripText.trainNameOrNumber.text
        case .stay: TripText.hotelOrAccommodationName.text
        case .reservation: TripText.reservationName.text
        case .activity: TripText.whatWouldYouLikeToDo.text
        case .freeTime: TripText.timeForYourself.text
        }
    }

    func scheduleSummary(in trip: TripPlan) -> String {
        if event.departureTime != nil || event.arrivalTime != nil {
            return [event.departureTime?.description, event.arrivalTime?.description].compactMap { $0 }.joined(separator: "\n")
        }
        guard let day = trip.days.first(where: { $0.id == event.startDayID }) else { return TripText.chooseADay.text }
        if event.startDayID == event.endDayID {
            let presentation = TripEventPresentation(event: event, day: day, trip: trip)
            return "\(dayLabel(day, trip: trip)) · \(presentation.timeText)"
        }
        guard let end = trip.days.first(where: { $0.id == event.endDayID }) else { return TripText.chooseAnEndDay.text }
        let startText = scheduleBoundary(day, minute: event.startMinute, label: event.kind.startLabel, in: trip)
        let endText = scheduleBoundary(end, minute: event.endMinute, label: event.kind.endLabel, in: trip)
        return "\(startText)\n\(endText)"
    }

    private func scheduleBoundary(_ day: TripDay, minute: Int?, label: String, in trip: TripPlan) -> String {
        let dateText = "\(label): \(dayLabel(day, trip: trip))"
        guard let minute else { return TripText.valueFlexibleTime(dateText).text }
        guard !trip.needsTimeZoneReview else { return TripText.valueReviewTimeZone(dateText).text }
        let time = TripScheduleClock.date(minute: minute, on: trip.date(for: day), calendar: trip.calendar)
        return "\(dateText) · \(TripScheduleText.time(time, relativeTo: time, calendar: trip.calendar))"
    }
}

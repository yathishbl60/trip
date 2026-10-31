import Foundation
import TripDomain

extension TripEventDraft {
    func time(for keyPath: WritableKeyPath<TripEvent, Int?>) -> Date {
        clock(arrival: keyPath == \TripEvent.endMinute).pickerDate
    }

    func setTime(_ date: Date, at keyPath: WritableKeyPath<TripEvent, Int?>) {
        setClockDate(date, arrival: keyPath == \TripEvent.endMinute)
    }

    func setTimeEnabled(_ enabled: Bool, at keyPath: WritableKeyPath<TripEvent, Int?>) {
        let arrival = keyPath == \TripEvent.endMinute
        setClock(enabled ? clock(arrival: arrival) : nil, arrival: arrival)
    }

    func dayLabel(_ day: TripDay, trip: TripPlan) -> String {
        "\(day.title) · \(trip.dateText(for: day))"
    }

    func days(for keyPath: WritableKeyPath<TripEvent, UUID>, in trip: TripPlan) -> [TripDay] {
        guard keyPath == \TripEvent.endDayID,
              let start = trip.days.firstIndex(where: { $0.id == event.startDayID }) else { return trip.days }
        return Array(trip.days[start...])
    }

    func setDay(_ dayID: UUID, at keyPath: WritableKeyPath<TripEvent, UUID>) {
        set(dayID, at: keyPath)
        guard keyPath == \TripEvent.startDayID,
              let start = originalDays.firstIndex(of: dayID),
              let end = originalDays.firstIndex(of: event.endDayID), start > end else { return }
        event.endDayID = dayID
    }
}

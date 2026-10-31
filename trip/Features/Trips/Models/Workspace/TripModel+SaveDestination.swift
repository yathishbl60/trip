import TripLocalization
import Foundation
import TripDomain

extension TripModel {
    func saveDaySummary(_ day: TripDay, in trip: TripPlan) -> String {
        "\(trip.dateText(for: day)) · \(trip.journeySummary(on: day))"
    }

    func saveToNewDay(_ place: Place, tripID: UUID) -> Bool {
        guard let trip = library.trip(tripID), trip.days.count < TripLimits.days else {
            presentation.notice = TripText.thisTripHasReachedItsDayLimitChooseAn.text
            return false
        }
        var day = TripDay(number: trip.days.count + 1)
        day.stops = [TripStop(place: place)]
        let saved = library.update(tripID) { plan in
            guard plan.days.count == trip.days.count else { return false }
            plan.days.append(day)
            return true
        }
        guard saved else { return false }
        presentation.notice = nil
        feedback.show(TripText.addedToValueValue(trip.title, day.title).text)
        return true
    }
}

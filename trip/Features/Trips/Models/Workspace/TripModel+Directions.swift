import TripLocalization
import Foundation
import TripDomain

extension TripModel {
    func dayDirectionsIssue(_ day: TripDay, tripID: UUID) -> String? {
        guard environment.showDirections != nil else { return TripText.directionsAreUnavailableInThisView.text }
        guard let current = library.trip(tripID)?.days.first(where: { $0.id == day.id }),
              !current.stops.isEmpty else { return TripText.addAPlaceToGetDirections.text }
        guard current.stops.count <= environment.maximumRoutePlaces else {
            return TripText.routesSupportUpToValuePlacesPerDay(TripText.number(environment.maximumRoutePlaces)).text
        }
        guard current.stops.allSatisfy({ $0.place.coordinate.isValid }) else {
            return TripText.aPlaceIsMissingItsMapLocation.text
        }
        return nil
    }

    func showDayDirections(dayID: UUID, tripID: UUID) {
        guard let day = library.trip(tripID)?.days.first(where: { $0.id == dayID }) else { return }
        if let issue = dayDirectionsIssue(day, tripID: tripID) { presentation.notice = issue; return }
        presentation.notice = nil
        environment.showDirections?(day.stops.map(\.place))
    }
}

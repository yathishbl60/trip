import Foundation
import TripDomain

extension TripController {
    func saveToNewDay(_ place: Place, tripID: UUID) {
        if model.saveToNewDay(place, tripID: tripID) { model.dismissDestination() }
    }
}

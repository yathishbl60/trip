import Foundation
import TripDomain

extension TripModel {
    func configureCollections() {
        collections.environment = TripCollectionsEnvironment(
            showPlace: environment.showPlace,
            showFeedback: { [weak feedback] in feedback?.show($0) },
            showNotice: { [weak presentation] in presentation?.notice = $0 },
            schedulePlace: { [weak self] in self?.scheduleCollectionPlace($0, on: $1, tripID: $2) }
        )
    }

    private func scheduleCollectionPlace(_ place: Place, on dayID: UUID, tripID: UUID) -> String? {
        _ = add(place, to: tripID, dayID: dayID)
        return presentation.notice
    }
}

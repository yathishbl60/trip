import TripDomain
import Foundation

extension TripLibraryModel {
    @discardableResult func updateDay(_ dayID: UUID, in tripID: UUID,
                                      edit: (inout TripDay) -> Bool) -> Bool {
        update(tripID) { plan in
            guard let index = plan.days.firstIndex(where: { $0.id == dayID }) else { return false }
            return edit(&plan.days[index])
        }
    }

    @discardableResult func updateCollection(_ collectionID: UUID, in tripID: UUID,
                                             edit: (inout TripCollection) -> Bool) -> Bool {
        update(tripID) { plan in
            guard let index = plan.collections.firstIndex(where: { $0.id == collectionID }) else { return false }
            return edit(&plan.collections[index])
        }
    }
}

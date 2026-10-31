import TripLocalization
import TripDomain
import Foundation

extension TripModel {
    func beginCollection(in tripID: UUID) {
        guard let trip = library.trip(tripID), trip.collections.count < TripLimits.collections else { return }
        presentation.collectionDraft = TripCollectionDraft(tripID: tripID)
    }

    func beginCollectionRename(_ collection: TripCollection, in tripID: UUID) {
        guard library.trip(tripID)?.collections.contains(where: { $0.id == collection.id }) == true else { return }
        presentation.collectionDraft = TripCollectionDraft(tripID: tripID, collection: collection)
    }

    func cancelCollection(_ draft: TripCollectionDraft) {
        if presentation.collectionDraft?.id == draft.id { presentation.collectionDraft = nil }
    }

    func commitCollection(_ draft: TripCollectionDraft) {
        guard draft.canSave else { return }
        let saved = library.update(draft.tripID) { trip in
            if let id = draft.collectionID {
                guard let index = trip.collections.firstIndex(where: { $0.id == id }) else { return false }
                trip.collections[index].title = draft.normalizedTitle
            } else {
                guard trip.collections.count < TripLimits.collections else { return false }
                trip.collections.append(TripCollection(title: draft.normalizedTitle))
            }
            return true
        }
        cancelCollection(draft)
        presentation.notice = saved ? nil : TripText.theCollectionCouldnTBeSavedTheTripMay.text
    }

    func deleteCollection(from tripID: UUID) {
        guard let id = presentation.collectionToDelete else { return }
        let removed = library.update(tripID) { trip in
            guard trip.collections.contains(where: { $0.id == id }) else { return false }
            trip.collections.removeAll { $0.id == id }
            return true
        }
        if removed { presentation.collectionToDelete = nil }
    }
}

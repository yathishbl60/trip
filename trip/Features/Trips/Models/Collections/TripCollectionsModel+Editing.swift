import TripLocalization
import TripDomain
import Foundation

extension TripCollectionsModel {
    func beginCollection(in tripID: UUID) {
        guard let trip = library.trip(tripID), trip.collections.count < TripLimits.collections else { return }
        draft = TripCollectionDraft(tripID: tripID)
    }

    func beginCollectionRename(_ collection: TripCollection, in tripID: UUID) {
        guard let current = self.collection(collection.id, in: tripID) else { return }
        draft = TripCollectionDraft(tripID: tripID, collection: current)
    }

    func cancelCollection(_ draft: TripCollectionDraft) {
        if self.draft?.id == draft.id { self.draft = nil }
    }

    func commitCollection(_ draft: TripCollectionDraft) {
        guard self.draft?.id == draft.id, draft.canSave else { return }
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
        showNotice(saved ? nil : TripText.theCollectionCouldnTBeSavedTheTripMay.text)
    }

    func requestDeletion(_ collectionID: UUID, tripID: UUID) {
        guard collection(collectionID, in: tripID) != nil else { return }
        deletion = TripCollectionDeletion(tripID: tripID, collectionID: collectionID)
    }

    func cancelDeletion(_ sessionID: UUID?) {
        if deletion?.id == sessionID { deletion = nil }
    }

    func deleteCollection(_ session: TripCollectionDeletion) {
        guard deletion?.id == session.id else { return }
        let removed = library.update(session.tripID) { trip in
            guard trip.collections.contains(where: { $0.id == session.collectionID }) else { return false }
            trip.collections.removeAll { $0.id == session.collectionID }
            return true
        }
        if removed { deletion = nil }
    }
}

import TripDomain
import SwiftUI

extension TripController {
    func collectionNaming(in tripID: UUID) -> Binding<Bool> {
        let draftID = model.presentation.collectionDraft?.id
        return Binding(get: { model.presentation.collectionDraft?.tripID == tripID }, set: { presented in
            guard !presented, let draftID,
                  let draft = model.presentation.collectionDraft,
                  draft.id == draftID else { return }
            model.cancelCollection(draft)
        })
    }

    func collectionTitle(_ draft: TripCollectionDraft) -> Binding<String> {
        Binding(get: { draft.title }, set: { draft.title = $0 })
    }

    var deletingCollection: Binding<Bool> {
        Binding(get: { model.presentation.collectionToDelete != nil },
                set: { if !$0 { model.presentation.collectionToDelete = nil } })
    }

    func beginCollection(in tripID: UUID) { model.beginCollection(in: tripID) }
    func renameCollection(_ item: TripCollection, in tripID: UUID) { model.beginCollectionRename(item, in: tripID) }
    func commitCollection(_ draft: TripCollectionDraft) { model.commitCollection(draft) }
    func requestCollectionDeletion(_ id: UUID) { model.presentation.collectionToDelete = id }
    func confirmCollectionDeletion(from tripID: UUID) { model.deleteCollection(from: tripID) }
    func save(_ place: Place, in collectionID: UUID, tripID: UUID) {
        if model.save(place, in: collectionID, tripID: tripID) { dismissDestination() }
    }
    func schedule(_ place: Place, on dayID: UUID, tripID: UUID) {
        _ = model.add(place, to: tripID, dayID: dayID)
    }
    func removeCollectionStops(_ offsets: IndexSet, from collection: TripCollection, tripID: UUID) {
        model.removeCollectionStops(offsets, from: collection, tripID: tripID)
    }
    func moveCollectionStops(_ offsets: IndexSet, to destination: Int,
                             in collection: TripCollection, tripID: UUID) {
        model.moveCollectionStops(offsets, to: destination, in: collection, tripID: tripID)
    }
}

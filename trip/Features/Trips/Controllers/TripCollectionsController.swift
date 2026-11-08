import TripDomain
import SwiftUI
import Foundation

@MainActor struct TripCollectionsController {
    let model: TripCollectionsModel

    func collectionNaming(in tripID: UUID) -> Binding<Bool> {
        let draftID = model.draft?.id
        return Binding(get: { model.draft?.tripID == tripID }, set: { presented in
            guard !presented, let draftID,
                  let draft = model.draft,
                  draft.id == draftID else { return }
            model.cancelCollection(draft)
        })
    }

    func collectionTitle(_ draft: TripCollectionDraft) -> Binding<String> {
        Binding(get: { draft.title }, set: { draft.title = $0 })
    }

    func deletingCollection(in tripID: UUID) -> Binding<Bool> {
        let sessionID = model.deletion?.id
        return Binding(get: { model.deletion?.tripID == tripID },
                       set: { if !$0 { model.cancelDeletion(sessionID) } })
    }

    func beginCollection(in tripID: UUID) { model.beginCollection(in: tripID) }
    func renameCollection(_ item: TripCollection, in tripID: UUID) { model.beginCollectionRename(item, in: tripID) }
    func commitCollection(_ draft: TripCollectionDraft) { model.commitCollection(draft) }
    func requestCollectionDeletion(_ id: UUID, tripID: UUID) { model.requestDeletion(id, tripID: tripID) }
    func confirmCollectionDeletion(_ session: TripCollectionDeletion) { model.deleteCollection(session) }
    func schedule(_ place: Place, on dayID: UUID, tripID: UUID) {
        model.schedule(place, on: dayID, tripID: tripID)
    }
    func showOnMap(_ place: Place) { model.environment.showPlace(place) }
    func removeCollectionStops(_ offsets: IndexSet, from collection: TripCollection, tripID: UUID) {
        model.removeCollectionStops(offsets, from: collection, tripID: tripID)
    }
    func moveCollectionStops(_ offsets: IndexSet, to destination: Int,
                             in collection: TripCollection, tripID: UUID) {
        model.moveCollectionStops(offsets, to: destination, in: collection, tripID: tripID)
    }
}

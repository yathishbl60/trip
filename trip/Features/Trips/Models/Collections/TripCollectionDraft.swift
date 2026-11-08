import TripLocalization
import Foundation
import Observation
import TripDomain

@MainActor @Observable final class TripCollectionDraft: Identifiable {
    let id = UUID()
    let tripID: UUID
    let collectionID: UUID?
    var title: String

    init(tripID: UUID, collection: TripCollection? = nil) {
        self.tripID = tripID
        collectionID = collection?.id
        title = collection?.title ?? ""
    }

    var normalizedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    var canSave: Bool { TripCollectionEditing.title(title) != nil }
    var navigationTitle: String { collectionID == nil ? TripText.newCollection.text : TripText.renameCollection.text }
    var validationMessage: String? {
        if normalizedTitle.count > TripLimits.titleCharacters {
            return TripText.useValueCharactersOrFewer(TripText.number(TripLimits.titleCharacters)).text
        }
        if !normalizedTitle.isEmpty, TripCollectionEditing.title(title) == nil { return TripText.collectionInvalidTitle.text }
        return nil
    }
}

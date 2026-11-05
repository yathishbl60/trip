import TripLocalization
import Foundation
import Observation
import TripDomain

@MainActor @Observable final class TripChecklistDraft: Identifiable {
    let id = UUID()
    let tripID: UUID
    let itemID: UUID?
    var title: String

    init(tripID: UUID, item: TripChecklistItem? = nil) {
        self.tripID = tripID
        itemID = item?.id
        title = item?.title ?? ""
    }

    var normalizedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    var navigationTitle: String { itemID == nil ? TripText.addToChecklist.text : TripText.editChecklistItem.text }
    var canSave: Bool { TripChecklistEditing.title(title) != nil }
}

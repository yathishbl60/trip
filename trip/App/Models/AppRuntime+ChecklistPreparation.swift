import Foundation
import TripDomain

extension AppRuntime {
    static func editableChecklistLibrary() async throws -> TripLibraryModel {
        let library = try await library()
        try Task.checkCancellation()
        guard activeScene?.trips.hasEditingSession != true else { throw TripDetailIntentError.editing }
        return library
    }

    static func renameChecklistItem(_ rawValue: String, title: String) async throws -> SavedTripChecklistEntity {
        guard let identity = TripChecklistIdentity(rawValue) else { throw TripChecklistIntentError.missingItem }
        guard let title = TripChecklistEditing.title(title) else { throw TripChecklistIntentError.invalidTitle }
        let library = try await editableChecklistLibrary()
        _ = try checklistEntity(identity.itemID, tripID: identity.tripID, library: library)
        library.update(identity.tripID) { TripChecklistEditing.rename(identity.itemID, to: title, in: &$0) }
        try await saveChecklist(library)
        return try checklistEntity(identity.itemID, tripID: identity.tripID, library: library)
    }

    static func addChecklistTemplate(_ template: TripChecklistTemplate, tripID: UUID) async throws -> [SavedTripChecklistEntity] {
        let library = try await editableChecklistLibrary()
        guard library.trip(tripID) != nil else { throw TripIntentError.missingTrip }
        var added: Int?
        library.update(tripID) { plan in
            added = TripChecklistEditing.appendTemplate(template, to: &plan)
            return (added ?? 0) > 0
        }
        guard added != nil else { throw TripChecklistIntentError.full }
        try await saveChecklist(library)
        guard let plan = library.trip(tripID) else { throw TripIntentError.missingTrip }
        let keys = Set(template.items.map(TripChecklistEditing.key))
        return plan.checklist.filter { keys.contains(TripChecklistEditing.key($0.title)) }
            .map { SavedTripChecklistEntity($0, plan: plan) }
    }
}

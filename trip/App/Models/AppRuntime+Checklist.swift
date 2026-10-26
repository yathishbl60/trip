import TripLocalization
import Foundation
import AppIntents
import TripDomain

extension AppRuntime {
    static func addChecklistItem(_ title: String, tripID: UUID) async throws -> SavedTripChecklistEntity {
        guard let title = TripChecklistEditing.title(title) else { throw TripChecklistIntentError.invalidTitle }
        let library = try await library()
        guard let plan = library.trip(tripID) else { throw TripIntentError.missingTrip }
        let key = TripChecklistEditing.key(title)
        if let existing = plan.checklist.first(where: { TripChecklistEditing.key($0.title) == key }) {
            try await saveChecklist(library)
            return try checklistEntity(existing.id, tripID: tripID, library: library)
        }
        guard plan.canAddChecklistItem else { throw TripChecklistIntentError.full }
        let item = TripChecklistItem(title: title)
        guard library.update(tripID, edit: { $0.checklist.append(item); return true }) else { throw TripIntentError.missingTrip }
        try await saveChecklist(library)
        return try checklistEntity(item.id, tripID: tripID, library: library)
    }

    static func setChecklistItem(_ rawValue: String, complete: Bool) async throws -> SavedTripChecklistEntity {
        guard let identity = TripChecklistIdentity(rawValue) else { throw TripChecklistIntentError.missingItem }
        let library = try await library()
        guard let plan = library.trip(identity.tripID), identity.resolve(in: plan) != nil else { throw TripChecklistIntentError.missingItem }
        library.update(identity.tripID) { plan in
            guard let index = plan.checklist.firstIndex(where: { $0.id == identity.itemID }),
                  plan.checklist[index].isComplete != complete else { return false }
            plan.checklist[index].isComplete = complete
            return true
        }
        try await saveChecklist(library)
        return try checklistEntity(identity.itemID, tripID: identity.tripID, library: library)
    }

    private static func checklistEntity(_ id: UUID, tripID: UUID, library: TripLibraryModel) throws -> SavedTripChecklistEntity {
        guard let current = library.trip(tripID), let item = current.checklist.first(where: { $0.id == id }) else {
            throw TripChecklistIntentError.missingItem
        }
        return SavedTripChecklistEntity(item, plan: current)
    }

    private static func saveChecklist(_ library: TripLibraryModel) async throws {
        await library.flush()
        guard library.saveError == nil else { throw TripIntentError.saveFailed }
        TripChecklistSnippetIntent.reload()
    }
}

nonisolated enum TripChecklistIntentError: LocalizedError {
    case invalidTitle, full, missingItem
    var errorDescription: String? {
        switch self {
        case .invalidTitle: TripText.useASingleChecklistItemWith1To80.text
        case .full: TripText.thisChecklistIsFullRemoveAnItemBeforeAdding.text
        case .missingItem: TripText.thisChecklistItemIsNoLongerAvailable.text
        }
    }
}

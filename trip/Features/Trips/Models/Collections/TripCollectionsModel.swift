import Foundation
import Observation
import TripDomain

@MainActor @Observable final class TripCollectionsModel {
    let library: TripLibraryModel
    var draft: TripCollectionDraft?
    var deletion: TripCollectionDeletion?
    var notice: String?
    var environment: TripCollectionsEnvironment
    var hasEditingSession: Bool { draft != nil || deletion != nil }

    init(library: TripLibraryModel, environment: TripCollectionsEnvironment = .init()) {
        self.library = library
        self.environment = environment
    }

    func trip(_ tripID: UUID) -> TripPlan? { library.trip(tripID) }

    func collection(_ collectionID: UUID, in tripID: UUID) -> TripCollection? {
        trip(tripID)?.collections.first { $0.id == collectionID }
    }

    func resetPresentation() {
        draft = nil
        deletion = nil
        notice = nil
    }

    func showNotice(_ message: String?) {
        notice = message
        environment.showNotice(message)
    }

    func schedule(_ place: Place, on dayID: UUID, tripID: UUID) {
        showNotice(environment.schedulePlace(place, dayID, tripID))
    }
}

struct TripCollectionDeletion: Identifiable {
    let id = UUID()
    let tripID: UUID
    let collectionID: UUID
}

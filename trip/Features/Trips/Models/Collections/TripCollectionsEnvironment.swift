import Foundation
import TripDomain

/// Parent-owned navigation and feedback remain outside the collection workflow.
@MainActor struct TripCollectionsEnvironment {
    var showPlace: (Place) -> Void = { _ in }
    var showFeedback: (String) -> Void = { _ in }
    var showNotice: (String?) -> Void = { _ in }
    var schedulePlace: (Place, UUID, UUID) -> String? = { _, _, _ in nil }
}

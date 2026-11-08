import AppIntents
import Foundation
import TripDomain

/// The parent supplies navigation and feedback without sharing its workflow state.
@MainActor struct TripChecklistEnvironment {
    var showFeedback: (String) -> Void = { _ in }
    var supportsReminders: () -> Bool = { false }
    var showReminders: (UUID) -> Void = { _ in }
    var entityIdentifier: (TripChecklistIdentity) -> EntityIdentifier? = { _ in nil }
}

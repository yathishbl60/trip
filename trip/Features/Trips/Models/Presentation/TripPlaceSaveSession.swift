import Foundation
import TripDomain

/// Reopening the same place starts a distinct native sheet presentation.
struct TripPlaceSaveSession: Identifiable {
    let id = UUID()
    let place: Place
}

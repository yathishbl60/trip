#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import Foundation

/// Identifies one origin/stop edit independently of the sheet that contains it.
nonisolated struct DirectionsPlacePicker: Identifiable, Sendable {
    let id = UUID()
    let target: DirectionsPlaceTarget

    var title: String {
        switch target {
        case .origin: TripText.startingPoint.text
        case .stop(nil): TripText.addStop.text
        case .stop: TripText.changeStop.text
        }
    }
}

nonisolated enum DirectionsPlaceTarget: Equatable, Sendable { case origin, stop(String?) }
#endif

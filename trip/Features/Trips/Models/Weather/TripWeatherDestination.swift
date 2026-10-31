import Foundation

nonisolated struct TripWeatherDestination: Identifiable, Equatable {
    let tripID: UUID
    let dayID: UUID
    var id: String { "\(tripID)/\(dayID)" }
}

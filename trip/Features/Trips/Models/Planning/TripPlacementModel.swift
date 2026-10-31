import Foundation
import Observation
import TripDomain
import TripLocalization

struct TripPlacementInput: Equatable {
    let tripID: UUID
    let days: [TripDay]
    let place: Place
}

@MainActor @Observable final class TripPlacementModel {
    private var input: TripPlacementInput?
    private var suggestion: TripSaveSuggestion?
    @ObservationIgnored private let ranking = TripPlacementRanking()
    @ObservationIgnored private var generation = 0

    func result(for input: TripPlacementInput) -> TripSaveSuggestion? {
        self.input == input ? suggestion : nil
    }

    func load(_ place: Place, in trip: TripPlan) async {
        generation += 1
        let token = generation
        let requested = TripPlacementInput(tripID: trip.id, days: trip.days, place: place)
        guard requested != input else { return }
        let insertion = await ranking.suggestion(place, in: trip)
        guard generation == token, !Task.isCancelled else { return }
        suggestion = Self.presentation(insertion, trip: trip)
        input = requested
    }

    func cancel() { generation += 1 }

    private static func presentation(_ insertion: TripPlaceInsertion?, trip: TripPlan) -> TripSaveSuggestion? {
        guard let insertion, let day = trip.days.first(where: { $0.id == insertion.dayID }),
              let name = insertion.nearbyName else { return nil }
        return TripSaveSuggestion(dayID: day.id, title: day.title, reason: TripText.planningNearby(name).text)
    }
}

private actor TripPlacementRanking {
    func suggestion(_ place: Place, in trip: TripPlan) -> TripPlaceInsertion? {
        TripPlaceInsertion.suggestions(for: place, in: trip).first { $0.nearbyName != nil }
    }
}

struct TripSaveSuggestion {
    let dayID: UUID
    let title: String
    let reason: String
}

import TripLocalization
import Foundation
import Observation
import TripDomain

@MainActor @Observable final class TripLookupModel {
    var question = ""
    var searchText = ""
    var processing = TripAIProcessing.onDevice
    var query = TripDetailQuery()
    var plan: TripSurfacePlan?
    var isSearching = false
    var error: String?
    var unavailableReason: String?
    @ObservationIgnored let client: TripAIClient<any TripDetailSearching>
    @ObservationIgnored var task: Task<Void, Never>?
    @ObservationIgnored var deadline: Task<Void, Never>?
    @ObservationIgnored var generation = 0

    init(client: TripAIClient<any TripDetailSearching>) { self.client = client }

    var results: [TripDetailResult] { plan.map { query.results(in: $0) } ?? [] }
    var canAsk: Bool {
        plan != nil && unavailableReason == nil && !isSearching
            && !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var heading: String {
        let scope = query.dayNumber.map { TripText.dayTitle($0).text } ?? TripText.wholeTrip.text
        let name = query.searchText.isEmpty ? "" : " · \(query.searchText)"
        return "\(query.category.title) · \(scope)\(name)"
    }
    var emptyMessage: String {
        guard plan != nil else { return TripText.thisTripIsNoLongerAvailableReturnToYour.text }
        return query.category == .unsupported
            ? TripText.askAboutSavedPlacesStaysFlightsReservationsOrTimes.text
            : TripText.noSavedDetailsMatchThisSearchTryTheWhole.text
    }

    func prepare(_ trip: TripPlan, question: String = "") {
        cancel()
        plan = TripSurfacePlan(trip)
        processing = .onDevice
        self.question = String(question.prefix(TripLimits.preferenceCharacters))
        searchText = ""
        query = TripDetailQuery()
        error = nil
        refreshAvailability()
        if !question.isEmpty { ask() }
    }

    func refresh(_ updated: TripSurfacePlan?) {
        guard let updated else { cancel(); plan = nil; return }
        guard updated != plan else { return }
        cancel()
        plan = updated
        error = TripText.yourItineraryChangedSearchAgainForTheLatestDetails.text
    }

    func setQuestion(_ value: String) {
        cancel()
        question = String(value.prefix(TripLimits.preferenceCharacters))
        error = nil
    }

    func chooseDetail(_ id: UUID) {
        cancel()
        question = ""
        searchText = ""
        query = TripDetailQuery(itemID: id)
    }

    func cancel() {
        generation += 1
        task?.cancel()
        deadline?.cancel()
        task = nil
        deadline = nil
        isSearching = false
    }
}

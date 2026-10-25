import TripLocalization
import Foundation
import MapKit
import Observation
import TripDomain

@MainActor @Observable final class PlaceAutocompleteModel: NSObject {
    var suggestions: [PlaceSearchSuggestion] = []
    var isLoading = false
    var error: String?
    @ObservationIgnored var completer: MKLocalSearchCompleter?
    @ObservationIgnored var completions: [String: MKLocalSearchCompletion] = [:]
    @ObservationIgnored var task: Task<Void, Never>?
    @ObservationIgnored var deadline: Task<Void, Never>?
    @ObservationIgnored var generation = 0

    func update(_ query: String, region: MKCoordinateRegion? = nil) {
        cancel()
        error = nil
        let query = PlaceSearchQuery(query)
        suggestions = query.isEmpty ? [] : suggestions.filter { query.matches([$0.title, $0.subtitle]) }
        guard !query.isEmpty else { completions = [:]; return }
        isLoading = true
        let token = generation
        task = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard let self, !Task.isCancelled, token == generation else { return }
            start(query.text, region: region)
        }
    }

    private func start(_ query: String, region: MKCoordinateRegion?) {
        let completer = MKLocalSearchCompleter()
        if let region { completer.region = region }
        completer.resultTypes = [.address, .pointOfInterest, .query]
        completer.delegate = self
        self.completer = completer
        completer.queryFragment = query
        let token = generation
        deadline = Task { [weak self] in
            try? await Task.sleep(for: .seconds(15))
            guard let self, !Task.isCancelled, token == generation else { return }
            cancel()
            error = TripText.suggestionsTookTooLongTryAgainOrSubmitYour.text
        }
    }

    func update(_ query: String, near coordinate: Coordinate?) {
        let region = coordinate.flatMap { point in
            point.isValid ? MKCoordinateRegion(center: point.location,
                latitudinalMeters: 30_000, longitudinalMeters: 30_000) : nil
        }
        update(query, region: region)
    }

    func cancel() {
        generation += 1
        task?.cancel()
        deadline?.cancel()
        completer?.delegate = nil
        completer?.cancel()
        completer = nil
        task = nil
        deadline = nil
        isLoading = false
    }
}

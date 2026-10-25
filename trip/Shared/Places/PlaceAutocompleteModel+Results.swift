import TripLocalization
import MapKit
import TripDomain

extension PlaceAutocompleteModel: @MainActor MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        guard completer === self.completer else { return }
        var values: [PlaceSearchSuggestion] = []
        var native: [String: MKLocalSearchCompletion] = [:]
        for completion in completer.results {
            let suggestion = PlaceSearchSuggestion(title: completion.title, subtitle: completion.subtitle)
            guard native[suggestion.id] == nil else { continue }
            values.append(suggestion)
            native[suggestion.id] = completion
            if values.count == 20 { break }
        }
        suggestions = values
        completions = native
        isLoading = false
        error = nil
        deadline?.cancel()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        guard completer === self.completer else { return }
        isLoading = false
        self.error = TripText.couldnTLoadSuggestionsTryAgainOrSubmitYour.text
        deadline?.cancel()
    }

    func resolve(_ id: String, using search: PlaceTextSearch) async throws -> [Place] {
        guard suggestions.contains(where: { $0.id == id }), let completion = completions[id] else {
            throw CancellationError()
        }
        return try await search.search(completion)
    }
}

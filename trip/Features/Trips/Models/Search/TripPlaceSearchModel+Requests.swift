import TripLocalization
import Foundation
import TripDomain

extension TripPlaceSearchModel {
    func search(_ query: String, near coordinate: Coordinate?, suggestionID: String? = nil,
                autocomplete: PlaceAutocompleteModel? = nil) async {
        guard allowsLiveSearch, !Task.isCancelled else { return }
        prepare(query)
        guard !query.isEmpty else { return }
        let token = generation
        do {
            try await Task.sleep(for: .milliseconds(350))
            guard token == generation else { return }
            try await fetch(query, near: coordinate, token: token, suggestionID: suggestionID, autocomplete: autocomplete)
        } catch {
            guard token == generation, !Task.isCancelled else { return }
            self.error = TripText.couldnTSearchAppleMapsTryAgain.text
        }
        if token == generation { isSearching = false; deadline?.cancel() }
    }

    private func fetch(_ query: String, near coordinate: Coordinate?, token: Int, suggestionID: String?,
                       autocomplete: PlaceAutocompleteModel?) async throws {
        let operation = PlaceTextSearch()
        self.operation = operation
        startDeadline(token)
        let results = try await withTaskCancellationHandler {
            try await resolve(query, near: coordinate, suggestionID: suggestionID,
                              autocomplete: autocomplete, using: operation)
        } onCancel: {
            Task { @MainActor in operation.cancel() }
        }
        guard token == generation, !Task.isCancelled else { return }
        places = results
        resolvedQuery = query
        self.operation = nil
    }

    private func resolve(_ query: String, near coordinate: Coordinate?, suggestionID: String?,
                         autocomplete: PlaceAutocompleteModel?, using operation: PlaceTextSearch) async throws -> [Place] {
        if let suggestionID, let autocomplete {
            return try await autocomplete.resolve(suggestionID, using: operation)
        }
        return try await operation.search(query, near: coordinate)
    }

    private func startDeadline(_ token: Int) {
        deadline = Task { [weak self] in
            try? await Task.sleep(for: .seconds(15))
            guard let self, !Task.isCancelled, token == generation else { return }
            cancel()
            error = TripText.searchTookTooLongTryAgain.text
        }
    }
}

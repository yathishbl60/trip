import SwiftUI
import TripDomain

@MainActor struct CatalogController {
    let model: ExploreModel

    var query: Binding<String> {
        Binding(get: { model.catalog.query }, set: updateQuery)
    }

    var searchPresentation: Binding<Bool> {
        Binding(get: { model.catalog.isSearchPresented }, set: updatePresentation)
    }

    func start(_ phase: ScenePhase = .active) async {
        if phase == .active { await model.start() }
        else { model.stop() }
    }

    func updateQuery(_ query: String) {
        model.updateSearchQuery(query)
    }

    func search() {
        model.submitSearch()
    }

    func chooseSuggestion(_ id: String) { model.chooseSuggestion(id) }
    func retrySuggestions() { model.retryAutocomplete() }

    func clearSearch() { model.clearSearch() }

    func choose(_ place: Place, saving: Bool = false) { model.chooseSearchResult(place, saving: saving) }

    func searchPresentationChanged(_ presented: Bool) {
        model.searchPresentationChanged(presented)
    }

    private func updatePresentation(_ presented: Bool) {
        guard model.catalog.isSearchPresented != presented else { return }
        model.searchPresentationChanged(presented)
    }
}

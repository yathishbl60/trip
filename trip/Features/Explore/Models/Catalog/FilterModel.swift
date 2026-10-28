import TripLocalization
import TripDomain
import Observation

@MainActor @Observable final class FilterModel {
    var isPresented = false
    var selected: Set<PlaceCategory> = []
    var rows: [CategoryRow] = []
    let categories: [PlaceCategory]
    var allSelected: Bool { selected.isEmpty }
    var symbol: String { allSelected ? "line.3.horizontal.decrease" : "line.3.horizontal.decrease.circle.fill" }

    var summary: String {
        if selected.count == 1, let category = selected.first { return category.title }
        return allSelected ? TripText.allCategories.text : TripText.categoryCount(selected.count).text
    }

    init(categories: [PlaceCategory] = PlaceCategory.allCases, selected: Set<PlaceCategory> = []) {
        self.categories = categories
        self.selected = selected.intersection(categories)
    }

    var effectiveCategories: Set<PlaceCategory> { selected.isEmpty ? Set(categories) : selected }

    var loadedPlaceCount: Int {
        rows.filter { effectiveCategories.contains($0.category) }.reduce(0) { $0 + $1.count }
    }

    var loadedPlacesDescription: String {
        let count = loadedPlaceCount
        return TripText.foundPlaceCount(count).text
    }

    func toggle(_ category: PlaceCategory) {
        if selected.contains(category) { selected.remove(category) }
        else { selected.insert(category) }
        if selected.count == categories.count { selected.removeAll() }
    }

    func updateCounts(_ counts: [PlaceCategory: Int]) {
        rows = categories.map {
            CategoryRow(category: $0, count: counts[$0, default: 0], isSelected: selected.contains($0))
        }
    }

    func includes(_ place: Place) -> Bool {
        effectiveCategories.contains(place.category)
    }
}

nonisolated struct CategoryRow: Identifiable, Sendable {
    let category: PlaceCategory
    let count: Int
    let isSelected: Bool
    var id: PlaceCategory { category }
    var checkmark: String { isSelected ? "checkmark.circle.fill" : "circle" }
}

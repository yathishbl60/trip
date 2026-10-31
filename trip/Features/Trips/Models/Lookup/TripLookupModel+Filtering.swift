import TripLocalization
import TripDomain

extension TripLookupModel {
    var dayTitle: String { query.dayNumber.map { TripText.dayTitle($0).text } ?? TripText.wholeTrip.text }
    var hasFilters: Bool {
        query.category != .all || query.dayNumber != nil || !query.searchText.isEmpty || query.itemID != nil
    }

    func setSearchText(_ text: String) {
        guard searchText != text else { return }
        cancel()
        searchText = String(text.prefix(80))
        question = ""
        error = nil
        let category = query.category == .unsupported ? .all : query.category
        query = TripDetailQuery(category: category, dayNumber: query.dayNumber, searchText: searchText)
    }

    func choose(_ category: TripDetailCategory) {
        cancel()
        question = ""
        error = nil
        query = TripDetailQuery(category: category, dayNumber: query.dayNumber, searchText: query.searchText)
    }

    func chooseDay(_ number: Int?) {
        cancel()
        question = ""
        error = nil
        query = TripDetailQuery(category: query.category, dayNumber: number, searchText: query.searchText)
    }

    func resetFilters() {
        cancel()
        searchText = ""
        question = ""
        error = nil
        query = TripDetailQuery()
    }
}

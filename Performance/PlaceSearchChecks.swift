import Foundation

enum PlaceSearchChecks {
    static func run() throws {
        try matching()
        try relevance()
        try duplicateListings()
        try detailScope()
    }

    private static func matching() throws {
        let query = PlaceSearchQuery("  ＣＡＦＥ\n Paris  ")
        try require(query.text == "ＣＡＦＥ Paris", "Service query retained accidental whitespace")
        try require(query.matches(["Café de Flore", "Paris"]), "Words did not match across name/address or accents")
        try require(!query.matches(["Café de Flore", "Bangkok"]), "Search accepted only one of the requested words")
        try require(PlaceSearchQuery("Los Angeles").matches(["America/Los_Angeles"]), "Identifier separators hid a city")
        try require(PlaceSearchQuery("กรุงเทพ").matches(["กรุงเทพมหานคร"]), "Non-Latin text stopped matching")
        try require(PlaceSearchQuery(" \n ").isEmpty, "Whitespace became a real query")
        try require(!PlaceSearchQuery("!!!").matches(["Cafe"]), "Punctuation unexpectedly matched every result")
    }

    private static func relevance() throws {
        var address = CheckFixtures.place("address", name: "East Hotel")
        address.address = "Blue House Lane"
        let prefix = CheckFixtures.place("prefix", name: "Blue House Annex")
        let exact = CheckFixtures.place("exact", name: "Blue House")
        let tie = CheckFixtures.place("tie", name: "Blue House Garden")
        let places = [address, prefix, exact, tie]
        let matches = PlaceSearchQuery("blue house").places(in: places)
        try require(matches.map(\.id) == [exact.id, prefix.id, tie.id, address.id], "Name relevance or stable ties changed")
        try require(PlaceSearchQuery("").places(in: places) == places, "Clearing a query reordered the catalog")
        try require(PlaceSearchQuery("hotel blue").places(in: places).contains(address), "Category/address matching failed")
        let catalog = (0..<110).map { CheckFixtures.place("cached-\($0)") } + [exact]
        let limited = PlaceSearchResults.unique(PlaceSearchQuery("blue house").places(in: catalog))
        try require(limited.map(\.id) == [exact.id], "Result limit hid a matching place beyond the first cached page")
    }

    private static func duplicateListings() throws {
        let first = CheckFixtures.place("first", name: "Café")
        let duplicate = CheckFixtures.place("second", name: "Cafe", longitude: 100.50001)
        let branch = CheckFixtures.place("branch", name: "Cafe", longitude: 100.51)
        let other = CheckFixtures.place("other", name: "Museum")
        let matches = PlaceSearchResults.unique([first, first, duplicate, branch, other])
        try require(matches.map(\.id) == [first.id, branch.id, other.id], "Duplicate suppression removed a separate branch/place")
        try require(PlaceSearchResults.unique(matches, limit: 2).count == 2, "Result limit was ignored")
        try require(PlaceSearchResults.unique(matches, limit: 0).isEmpty, "Zero-capacity search retained a result")
    }

    private static func detailScope() throws {
        var trip = TripJourneyFixtures.plan()
        trip.events[1].title = "Riverside hotel"
        trip.events[1].location = "Bangkok"
        let plan = TripSurfacePlan(trip)
        let matches = TripDetailQuery(category: .stays, dayNumber: 2, searchText: "Bangkok riverside").results(in: plan)
        try require(matches.count == 1 && matches[0].day.number == 2, "Text search lost day/category scope")
        let wrongKind = TripDetailQuery(category: .travel, searchText: "Riverside").results(in: plan)
        try require(wrongKind.isEmpty, "Name search bypassed category filtering")
        let exact = TripDetailQuery(searchText: "hotel", itemID: trip.events[0].id).results(in: plan)
        try require(exact.isEmpty, "Text search bypassed exact item identity")
    }
}

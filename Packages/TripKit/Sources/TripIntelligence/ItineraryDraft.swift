import FoundationModels

@Generable nonisolated struct ItineraryDraft {
    @Guide(description: "The requested number of days, between one and five", .count(1...5))
    var days: [ItineraryDraftDay]
}

@Generable nonisolated struct ItineraryDraftDay {
    @Guide(description: "A short theme for the day, with no invented facts")
    var theme: String
    @Guide(description: "Indices of supplied places in visiting order. Never repeat an index.", .count(0...24))
    var placeIndices: [Int]
}

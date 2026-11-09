import TripStorage

@MainActor enum AppExploreServices {
    static func makeHistory() -> PlaceHistoryModel {
        PlaceHistoryModel(store: RecentPlaceStore())
    }
}

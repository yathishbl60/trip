#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

public nonisolated enum TripDetailCategory: String, CaseIterable, Sendable {
    case all, stays, travel, reservations, places, freeTime, untimed, unsupported

    public var title: String {
        switch self {
        case .all: TripText.itinerary.text
        case .stays: TripText.stays.text
        case .travel: TripText.flightsAndTrains.text
        case .reservations: TripText.reservations.text
        case .places: TripText.places.text
        case .freeTime: TripText.freeTime.text
        case .untimed: TripText.timesToConfirm.text
        case .unsupported: TripText.tryASavedItineraryDetail.text
        }
    }

    public func includes(_ item: TripSurfaceItem) -> Bool {
        switch self {
        case .all: true
        case .stays: item.kind == .stay
        case .travel: item.kind?.isTransport == true
        case .reservations: item.kind == .reservation
        case .places: item.kind == nil
        case .freeTime: item.kind == .freeTime
        case .untimed: item.startsAt == nil
        case .unsupported: false
        }
    }
}

public nonisolated struct TripDetailQuery: Sendable {
    public let category: TripDetailCategory
    public let dayNumber: Int?
    public let searchText: String
    public let itemID: UUID?

    public init(category: TripDetailCategory = .all, dayNumber: Int? = nil, searchText: String = "", itemID: UUID? = nil) {
        self.category = category
        self.dayNumber = dayNumber
        self.searchText = PlaceSearchQuery(String(searchText.prefix(80))).text
        self.itemID = itemID
    }

    public func results(in plan: TripSurfacePlan) -> [TripDetailResult] {
        var seen: Set<UUID> = []
        let search = PlaceSearchQuery(searchText)
        return plan.days.filter { dayNumber == nil || $0.number == dayNumber }.flatMap { day in
            day.agenda.filter { item in
                category.includes(item) && matches(item, search: search) && seen.insert(item.id).inserted
            }.map { TripDetailResult(item: $0, day: day) }
        }
    }

    private func matches(_ item: TripSurfaceItem, search: PlaceSearchQuery) -> Bool {
        guard itemID == nil || itemID == item.id else { return false }
        return search.matches([item.title, item.detail, item.kind?.title ?? ""])
    }
}

public nonisolated struct TripDetailResult: Identifiable, Sendable {
    public var id: UUID { item.id }
    public let item: TripSurfaceItem
    public let day: TripSurfaceDay
    public var source: String {
        TripText.dayValueValue(TripText.number(day.number), day.dateText).text
    }

    public var shareText: String {
        [item.title, source, item.timeText, item.detail].filter { !$0.isEmpty }.joined(separator: "\n")
    }
}

public nonisolated protocol TripDetailSearching: Sendable {
    func interpret(_ question: String, days: [TripSurfaceDay], now: Date) async throws -> TripDetailQuery
}

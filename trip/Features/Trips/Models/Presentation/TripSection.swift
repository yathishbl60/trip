import TripLocalization

nonisolated enum TripSection: String, CaseIterable, Sendable {
    case itinerary, today, map, checklist, collections, details

    var title: String {
        switch self {
        case .itinerary: TripText.itinerary.text
        case .today: TripText.today.text
        case .map: TripText.map.text
        case .checklist: TripText.checklist.text
        case .collections: TripText.collections.text
        case .details: TripText.askMyTrip.text
        }
    }

    var symbol: String {
        switch self {
        case .itinerary: "list.bullet"
        case .today: "sun.horizon"
        case .map: "map"
        case .checklist: "checklist"
        case .collections: "square.stack"
        case .details: "text.magnifyingglass"
        }
    }

    var destination: TripDetailRoute.Destination? {
        switch self {
        case .itinerary: nil
        case .today: .today
        case .map: .map
        case .checklist: .checklist
        case .collections: .collections
        case .details: .lookup
        }
    }
}

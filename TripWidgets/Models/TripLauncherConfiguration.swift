#if os(iOS)
import AppIntents

enum TripLauncherDestination: String, AppEnum {
    case itinerary, checklist, nextStep
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "trip_destination") }
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [.itinerary: DisplayRepresentation(title: "itinerary"), .checklist: DisplayRepresentation(title: "checklist"), .nextStep: DisplayRepresentation(title: "next_item")]
    }
    var symbol: String {
        switch self {
        case .itinerary: "suitcase.rolling"
        case .checklist: "checklist"
        case .nextStep: "arrow.right.circle"
        }
    }
}

struct TripLauncherConfiguration: ControlConfigurationIntent {
    static var title: LocalizedStringResource { "open_saved_trip" }
    @Parameter(title: "trip") var trip: SavedTripEntity?
    @Parameter(title: "open", default: .itinerary) var destination: TripLauncherDestination
}
#endif

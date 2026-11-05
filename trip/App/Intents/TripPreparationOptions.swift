import AppIntents
import TripDomain

enum TripChecklistPreset: String, AppEnum {
    case essentials, city, beach, outdoors
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "intent_checklist_preset") }
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [.essentials: DisplayRepresentation(title: "travel_essentials"), .city: DisplayRepresentation(title: "city_break"),
         .beach: DisplayRepresentation(title: "beach_days"), .outdoors: DisplayRepresentation(title: "outdoors")]
    }

    var template: TripChecklistTemplate {
        switch self {
        case .essentials: .essentials
        case .city: .city
        case .beach: .beach
        case .outdoors: .outdoors
        }
    }
}

enum TripNewEventKind: String, AppEnum {
    case flight, train, stay, reservation, activity, freeTime
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "intent_new_event_kind") }
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [.flight: DisplayRepresentation(title: "flight"), .train: DisplayRepresentation(title: "train"),
         .stay: DisplayRepresentation(title: "hotel_stay"), .reservation: DisplayRepresentation(title: "reservation"),
         .activity: DisplayRepresentation(title: "personal_activity"), .freeTime: DisplayRepresentation(title: "free_time")]
    }

    var kind: TripEventKind {
        switch self {
        case .flight: .flight
        case .train: .train
        case .stay: .stay
        case .reservation: .reservation
        case .activity: .activity
        case .freeTime: .freeTime
        }
    }
}

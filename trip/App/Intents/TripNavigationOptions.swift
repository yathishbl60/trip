import AppIntents

extension TripSection: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "intent_trip_section") }
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [.itinerary: DisplayRepresentation(title: "itinerary"), .today: DisplayRepresentation(title: "today"),
         .map: DisplayRepresentation(title: "map"), .checklist: DisplayRepresentation(title: "checklist"),
         .collections: DisplayRepresentation(title: "collections"), .details: DisplayRepresentation(title: "ask_my_trip")]
    }
}

extension TripWorkspaceTool: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "intent_trip_tool") }
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [.tripDetails: DisplayRepresentation(title: "edit_trip"), .calendar: DisplayRepresentation(title: "travel_export_to_calendar"),
         .reminders: DisplayRepresentation(title: "travel_export_to_reminders")]
    }
}

extension TripDayTool: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "intent_day_tool") }
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [.schedule: DisplayRepresentation(title: "edit_schedule"), .planning: DisplayRepresentation(title: "planning_Preview"),
         .weather: DisplayRepresentation(title: "travel_weather_for_day"), .addPlaces: DisplayRepresentation(title: "add_places"),
         .map: DisplayRepresentation(title: "show_day_on_map"), .directions: DisplayRepresentation(title: "directions"),
         .stopOrder: DisplayRepresentation(title: "suggest_stop_order")]
    }
}

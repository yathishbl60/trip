nonisolated enum TripWorkspaceTool: String, CaseIterable, Sendable {
    case tripDetails, calendar, reminders
}

nonisolated enum TripDayTool: String, CaseIterable, Sendable {
    case schedule, planning, weather, addPlaces, map
}

/// Shared editing limits used by planning workflows and their controls.
public nonisolated enum TripLimits {
    public static let trips = 100
    public static let days = 30
    public static let collections = 30
    public static let stops = 100
    public static let events = 300
    public static let checklistItems = 100
    public static let titleCharacters = 80
    public static let noteCharacters = 1_000
    public static let planningPlaces = 24
    public static let preferenceCharacters = 500
    public static let planningDays = 1...5
    public static let visitMinutes = 5...720
    public static let travelMinutes = 0...720
    public static let bufferMinutes = 0...180
}

import SiriEvaluations
import Testing

enum TripSiriDefinitions {
    static let app = IntentDefinitions(bundleIdentifier: "com.native.trip")
    static let trip = app.entities["SavedTripEntity"]
    static let openTrip = app.intents["OpenSavedTripIntent"]
    static let readTrip = app.intents["ReadTripItineraryIntent"]
    static let readChecklist = app.intents["ReadTripChecklistIntent"]

    static var noMutations: Calls {
        Calls(.disallowed) {
            app.intents["CreateTripIntent"]
            app.intents["AddTripChecklistItemIntent"]
            app.intents["SetTripChecklistItemIntent"]
            app.intents["SetTripVisitTimingIntent"]
            app.intents["MarkSavedTripPlaceVisitedIntent"]
            app.intents["VisitNextTripStopIntent"]
            app.intents["UndoTripVisitIntent"]
            app.intents["StartTripDayIntent"]
            app.intents["EndTripDayIntent"]
        }
    }
}

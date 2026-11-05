import SiriEvaluations
import Testing

enum TripSiriSkillScenarios {
    static var planning: SiriScenario {
        SiriScenario {
            UserTurn("In Trip, help me plan a day around my saved flight. Ask me what you need; don't edit anything yet.") {
                Loads(.required) { TripSiriDefinitions.app.skills["trip-day-planning"] }
                TripSiriDefinitions.noMutations
            }
        }
    }

    static var preparation: SiriScenario {
        SiriScenario {
            UserTurn("Help me prepare for departure and review what is left to pack in Trip. Don't add or complete items yet.") {
                Loads(.required) { TripSiriDefinitions.app.skills["trip-departure-preparation"] }
                TripSiriDefinitions.noMutations
            }
        }
    }

    static var booking: SiriScenario {
        SiriScenario {
            UserTurn("Help me put a flight confirmation into my itinerary in Trip. Ask for the document and trip; don't save anything yet.") {
                Loads(.required) { TripSiriDefinitions.app.skills["trip-booking-review"] }
                TripSiriDefinitions.noMutations
            }
        }
    }
}

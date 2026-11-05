import Foundation
import AppIntentsTesting
import SiriEvaluations

enum TripSiriNavigationScenarios {
    static var today: SiriScenario {
        SiriScenario {
            UserTurn("Open the Today section of my Siri Review trip in Trip.") {
                Calls {
                    TripSiriDefinitions.app.intents["OpenTripSectionIntent"].expect(
                        trip: TripSiriDefinitions.trip.expectIdentifier(TripSiriFixture.identifier),
                        section: .matches(#Predicate<AnyAppEnum> { $0.typeIdentifier == "TripSection" && $0.rawValue == "today" }))
                }
                Finds { TripSiriDefinitions.trip.expectIdentifier(TripSiriFixture.identifier) }
                TripSiriDefinitions.noMutations
            }
        }
    }

    static var dayMap: SiriScenario {
        SiriScenario {
            UserTurn("Show day two of my Siri Review trip on the map inside Trip. Don't start directions or tracking.") {
                Calls {
                    TripSiriDefinitions.app.intents["OpenTripDayToolIntent"].expect(
                        trip: TripSiriDefinitions.trip.expectIdentifier(TripSiriFixture.identifier),
                        day: .matches(#Predicate<Int> { $0 == 2 }),
                        tool: .matches(#Predicate<AnyAppEnum> { $0.typeIdentifier == "TripDayTool" && $0.rawValue == "map" }))
                }
                Finds { TripSiriDefinitions.trip.expectIdentifier(TripSiriFixture.identifier) }
                Calls(.disallowed) { TripSiriDefinitions.app.intents["DirectionsToSavedTripPlaceIntent"] }
                TripSiriDefinitions.noMutations
            }
        }
    }
}

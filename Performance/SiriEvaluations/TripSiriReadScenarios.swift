import SiriEvaluations
import Testing

enum TripSiriReadScenarios {
    static var navigation: SiriScenarioLoader {
        SiriScenarioLoader {
            SiriScenario {
                UserTurn("Open my saved trips in Trip.") {
                    Calls { TripSiriDefinitions.app.intents["OpenTripsIntent"] }
                    TripSiriDefinitions.noMutations
                }
            }
            SiriScenario {
                UserTurn("Open the Explore map in Trip.") {
                    Calls { TripSiriDefinitions.app.intents["OpenExploreIntent"] }
                    TripSiriDefinitions.noMutations
                }
            }
        }
    }

    static var itinerary: SiriScenario {
        SiriScenario {
            UserTurn("Read the itinerary for my Siri Review trip in Trip. Don't change anything.") {
                Calls {
                    TripSiriDefinitions.readTrip.expect(
                        trip: TripSiriDefinitions.trip.expectIdentifier(TripSiriFixture.identifier))
                        .result(.contains(TripSiriFixture.name))
                }
                Finds { TripSiriDefinitions.trip.expectIdentifier(TripSiriFixture.identifier) }
                TripSiriDefinitions.noMutations
            }
        }
    }

    static var checklist: SiriScenario {
        SiriScenario {
            UserTurn("What's still on the checklist for my Siri Review trip in Trip? Just read it.") {
                Calls {
                    TripSiriDefinitions.readChecklist.expect(
                        trip: TripSiriDefinitions.trip.expectIdentifier(TripSiriFixture.identifier))
                        .result(.contains("Sample umbrella"))
                }
                Finds { TripSiriDefinitions.trip.expectIdentifier(TripSiriFixture.identifier) }
                TripSiriDefinitions.noMutations
            }
        }
    }

    static var onscreen: SiriScenario {
        SiriScenario {
            UserTurn("Read this trip's itinerary in Trip. Don't change it.") {
                OnScreen { TripSiriDefinitions.trip.expectIdentifier(TripSiriFixture.identifier) }
                Calls {
                    TripSiriDefinitions.readTrip.expect(
                        trip: TripSiriDefinitions.trip.expectIdentifier(TripSiriFixture.identifier))
                        .result(.contains(TripSiriFixture.name))
                }
                TripSiriDefinitions.noMutations
            }
        }
    }
}

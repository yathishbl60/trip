import TripLocalization
import Foundation

enum TripPlanningPace: String, CaseIterable, Identifiable {
    case relaxed = "Relaxed", balanced = "Balanced", full = "Full days"
    var id: Self { self }

    var title: String {
        switch self {
        case .relaxed: TripText.relaxed.text
        case .balanced: TripText.balanced.text
        case .full: TripText.fullDays.text
        }
    }
    var prompt: String {
        switch self {
        case .relaxed: "A relaxed pace. Leave room for breaks between the selected places."
        case .balanced: "A balanced pace with room to explore between the selected places."
        case .full: "Full days with the selected places grouped into an efficient visiting order."
        }
    }
}

enum TripPlanningFocus: String, CaseIterable, Identifiable {
    case variety = "A bit of everything", food = "Food", culture = "Arts & culture", outdoors = "Outdoors"
    var id: Self { self }

    var title: String {
        switch self {
        case .variety: TripText.aBitOfEverything.text
        case .food: TripText.food.text
        case .culture: TripText.artsCulture.text
        case .outdoors: TripText.outdoors.text
        }
    }
    var prompt: String {
        switch self {
        case .variety: "Mix the kinds of places throughout the itinerary."
        case .food: "Use selected food places as anchors for each day where possible."
        case .culture: "Use selected arts and cultural places as anchors where possible."
        case .outdoors: "Use selected outdoor places as anchors where possible."
        }
    }
}

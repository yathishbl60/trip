#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

public nonisolated struct TripChecklistItem: Codable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var isComplete: Bool

    public init(title: String) {
        id = UUID()
        self.title = title
        isComplete = false
    }
}

public nonisolated enum TripChecklistTemplate: String, CaseIterable, Identifiable, Sendable {
    case essentials = "Travel essentials"
    case city = "City break"
    case beach = "Beach days"
    case outdoors = "Outdoors"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .essentials: TripText.travelEssentials.text
        case .city: TripText.cityBreak.text
        case .beach: TripText.beachDays.text
        case .outdoors: TripText.outdoors.text
        }
    }

    public var items: [String] {
        switch self {
        case .essentials:
            [TripText.checkTravelDocuments.text, TripText.confirmReservations.text, TripText.downloadOfflineMaps.text, TripText.phoneCharger.text, TripText.travelAdapter.text]
        case .city:
            [TripText.comfortableWalkingShoes.text, TripText.dayBag.text, TripText.reusableWaterBottle.text, TripText.checkAttractionReservations.text]
        case .beach:
            [TripText.swimwear.text, TripText.sunscreen.text, TripText.sunHat.text, TripText.beachTowel.text, TripText.waterproofPouch.text]
        case .outdoors:
            [TripText.checkTheWeather.text, TripText.walkingShoes.text, TripText.rainLayer.text, TripText.waterBottle.text, TripText.downloadTrailMaps.text]
        }
    }
}

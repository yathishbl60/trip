import TripLocalization
import TripDomain
import Observation
import Foundation

@MainActor @Observable final class TripAssistantSelection {
    private(set) var places: [Place] = []
    private(set) var selectedIDs: Set<String> = []
    var query = ""

    var selectedPlaces: [Place] { places.filter { selectedIDs.contains($0.id) } }
    var summary: String { TripText.valueOfValueSelected(TripText.number(selectedIDs.count), TripText.number(places.count)).text }
    var canSelectAll: Bool { places.count <= TripLimits.planningPlaces }
    var filteredPlaces: [Place] {
        PlaceSearchQuery(query).places(in: places)
    }

    func reset(_ places: [Place]) {
        self.places = places
        selectedIDs = Set(places.prefix(TripLimits.planningPlaces).map(\.id))
        query = ""
    }

    func reconcile(_ places: [Place]) -> Bool {
        guard self.places != places else { return false }
        let existingIDs = Set(self.places.map(\.id))
        self.places = places
        selectedIDs.formIntersection(places.map(\.id))
        let additions = places.filter { !existingIDs.contains($0.id) }
        selectedIDs.formUnion(additions.prefix(max(0, TripLimits.planningPlaces - selectedIDs.count)).map(\.id))
        return true
    }

    func canSelect(_ id: String) -> Bool {
        selectedIDs.contains(id) || selectedIDs.count < TripLimits.planningPlaces
    }

    func setSelected(_ value: Bool, id: String) -> Bool {
        guard places.contains(where: { $0.id == id }), value != selectedIDs.contains(id), canSelect(id) else { return false }
        if value { selectedIDs.insert(id) } else { selectedIDs.remove(id) }
        return true
    }

    func selectAll(_ selected: Bool) {
        selectedIDs = selected ? Set(places.prefix(TripLimits.planningPlaces).map(\.id)) : []
    }
}

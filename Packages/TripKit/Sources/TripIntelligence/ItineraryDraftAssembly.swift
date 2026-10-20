import TripDomain

nonisolated enum ItineraryDraftAssembly {
    static func assemble(_ draft: ItineraryDraft, places: [Place], count: Int) -> [TripDay] {
        var used: Set<Int> = []
        let capacity = (places.count + count - 1) / count
        var days = (1...count).map { TripDay(number: $0) }
        for (index, item) in draft.days.prefix(count).enumerated() {
            days[index].notes = String(item.theme.prefix(200))
            for placeIndex in item.placeIndices where days[index].stops.count < capacity {
                guard places.indices.contains(placeIndex), used.insert(placeIndex).inserted else { continue }
                days[index].stops.append(TripStop(place: places[placeIndex]))
            }
        }
        includeRemaining(places, used: used, capacity: capacity, days: &days)
        return days
    }

    private static func includeRemaining(_ places: [Place], used: Set<Int>, capacity: Int, days: inout [TripDay]) {
        for index in places.indices where !used.contains(index) {
            let available = days.indices.filter { days[$0].stops.count < capacity }
            guard let day = available.min(by: {
                distance(from: places[index], to: days[$0]) < distance(from: places[index], to: days[$1])
            }) else { continue }
            days[day].stops.append(TripStop(place: places[index]))
            days[day].notes = ""
        }
    }

    private static func distance(from place: Place, to day: TripDay) -> Double {
        day.stops.map { place.coordinate.distance(to: $0.place.coordinate) }.min() ?? 0
    }
}

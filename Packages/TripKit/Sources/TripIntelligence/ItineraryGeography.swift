import TripDomain
import Foundation

nonisolated enum ItineraryGeography {
    static func context(_ places: [Place]) -> String {
        places.indices.map { index in
            let neighbors = places.indices.filter { $0 != index }.sorted {
                places[index].coordinate.distance(to: places[$0].coordinate)
                    < places[index].coordinate.distance(to: places[$1].coordinate)
            }.prefix(3)
            let distances = neighbors.map { neighbor in
                let meters = Int(places[index].coordinate.distance(to: places[neighbor].coordinate).rounded())
                return "\(neighbor) (\(meters) m)"
            }.joined(separator: ", ")
            return "\(index) is closest to: \(distances)"
        }.joined(separator: "\n")
    }

    static func refine(_ days: [TripDay]) async throws -> [TripDay] {
        let service = TripStopOrderService()
        var refined: [TripDay] = []
        for var day in days {
            try Task.checkCancellation()
            if day.stops.count >= 3 {
                let proposal = try await service.suggestion(for: day)
                _ = proposal.apply(to: &day)
            }
            refined.append(day)
        }
        return refined
    }
}

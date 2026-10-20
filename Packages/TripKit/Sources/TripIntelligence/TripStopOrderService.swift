#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation
import TripDomain

/// Bounded, cancellable local planning; no language model or network request.
public actor TripStopOrderService: TripStopOrderSuggesting {
    public init() {}

    public func suggestion(for day: TripDay) throws -> TripStopOrderProposal {
        guard (3...TripLimits.stops).contains(day.stops.count),
              Set(day.stops.map(\.id)).count == day.stops.count,
              day.stops.allSatisfy({ $0.place.coordinate.isValid }) else { throw OrderError.invalidPlaces }
        let matrix = try distances(for: day)
        let original = Array(day.stops.indices)
        let greedy = try nearestOrder(matrix)
        let candidates = try [refine(original, matrix: matrix), refine(greedy, matrix: matrix)]
        let best = candidates.min { length($0, matrix: matrix) < length($1, matrix: matrix) } ?? original
        return TripStopOrderProposal(day: day, suggestedIDs: best.map { day.stops[$0].id },
            originalDistance: length(original, matrix: matrix), suggestedDistance: length(best, matrix: matrix))
    }

    private func distances(for day: TripDay) throws -> [[Double]] {
        var result = Array(repeating: Array(repeating: 0.0, count: day.stops.count), count: day.stops.count)
        for start in day.stops.indices {
            try Task.checkCancellation()
            for end in (start + 1)..<day.stops.count {
                let distance = day.stops[start].place.coordinate.distance(to: day.stops[end].place.coordinate)
                result[start][end] = distance
                result[end][start] = distance
            }
        }
        return result
    }

    private func nearestOrder(_ matrix: [[Double]]) throws -> [Int] {
        var order = [0]
        var remaining = Array(1..<matrix.count)
        while let last = order.last, !remaining.isEmpty {
            try Task.checkCancellation()
            guard let nearest = remaining.indices.min(by: {
                matrix[last][remaining[$0]] < matrix[last][remaining[$1]]
            }) else { break }
            order.append(remaining.remove(at: nearest))
        }
        return order
    }

    private func refine(_ initial: [Int], matrix: [[Double]]) throws -> [Int] {
        var order = initial
        for _ in 0..<20 {
            try Task.checkCancellation()
            guard let range = improvingReversal(order, matrix: matrix) else { break }
            order.replaceSubrange(range, with: Array(order[range].reversed()))
        }
        return order
    }

    private func improvingReversal(_ order: [Int], matrix: [[Double]]) -> ClosedRange<Int>? {
        for start in 1..<(order.count - 1) {
            for end in (start + 1)..<order.count {
                let before = matrix[order[start - 1]][order[start]]
                let after = matrix[order[start - 1]][order[end]]
                let oldTail = end + 1 < order.count ? matrix[order[end]][order[end + 1]] : 0
                let newTail = end + 1 < order.count ? matrix[order[start]][order[end + 1]] : 0
                if before + oldTail > after + newTail + 0.5 { return start...end }
            }
        }
        return nil
    }

    private func length(_ order: [Int], matrix: [[Double]]) -> Double {
        zip(order, order.dropFirst()).reduce(0) { $0 + matrix[$1.0][$1.1] }
    }
}

private nonisolated enum OrderError: LocalizedError {
    case invalidPlaces
    var errorDescription: String? { TripText.chooseADayWith3100PlacesEachWith.text }
}

import Foundation
import CoreGraphics
#if !TRIP_STANDALONE
import TripDomain
#endif

extension MarkerLayoutEngine {
    func rank(_ request: LayoutRequest) throws -> [ProjectedPlace] {
        let zoomStyles = request.policy.styles(at: request.zoom)
        var ranked: [RankedPlace] = []
        ranked.reserveCapacity(request.candidates.count)
        for candidate in request.candidates {
            try Task.checkCancellation()
            guard candidate.point.x.isFinite, candidate.point.y.isFinite,
                  candidate.place.coordinate.isValid,
                  canAppear(candidate, in: request, zoomStyles: zoomStyles) else { continue }
            ranked.append(RankedPlace(candidate: candidate, priority: priority(for: candidate, in: request),
                                      isSelected: candidate.place.id == request.selectedID))
        }
        ranked.sort(by: RankedPlace.precedes)
        return try uniqueCandidates(ranked, limit: request.policy.candidateLimit)
    }

    /// Offscreen representations must not consume the budget before visible candidates are ranked.
    private func canAppear(_ candidate: ProjectedPlace, in request: LayoutRequest, zoomStyles: [MarkerStyle]) -> Bool {
        eligibleStyles(for: candidate.place.id, request: request, zoomStyles: zoomStyles).contains {
            fitsViewport(candidate, style: $0, in: request)
        }
    }

    private func uniqueCandidates(_ ranked: [RankedPlace], limit: Int) throws -> [ProjectedPlace] {
        var identifiers: Set<String> = []
        var result: [ProjectedPlace] = []
        result.reserveCapacity(min(limit, ranked.count))
        for value in ranked {
            try Task.checkCancellation()
            guard identifiers.insert(value.candidate.place.id).inserted else { continue }
            result.append(value.candidate)
            if result.count == limit { break }
        }
        return result
    }

    private func priority(for candidate: ProjectedPlace, in request: LayoutRequest) -> Double {
        let distanceFromCenter = hypot(candidate.point.x - request.viewport.midX,
                                       candidate.point.y - request.viewport.midY)
        return request.policy.priority(importance: candidate.place.importance, distanceFromCenter: distanceFromCenter,
                                       previousStyle: request.previous[candidate.place.id])
    }
}

nonisolated private struct RankedPlace {
    let candidate: ProjectedPlace
    let priority: Double
    let isSelected: Bool

    static func precedes(_ lhs: Self, _ rhs: Self) -> Bool {
        if lhs.isSelected != rhs.isSelected { return lhs.isSelected }
        if lhs.priority != rhs.priority { return lhs.priority > rhs.priority }
        return lhs.candidate.place.id < rhs.candidate.place.id
    }
}

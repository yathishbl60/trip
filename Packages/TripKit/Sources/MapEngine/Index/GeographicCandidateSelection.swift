/// Reserve half the unchanged budget across viewport cells, then fill by priority.
nonisolated struct GeographicCandidateSelection {
    private var overall: GeographicCandidateBuffer
    private var cells: [GeographicCandidateBuffer]
    private let limit: Int

    init(limit: Int, cellCount: Int) {
        self.limit = limit
        overall = GeographicCandidateBuffer(limit: limit)
        cells = (0..<cellCount).map { _ in GeographicCandidateBuffer(limit: limit / 2 / max(cellCount, 1)) }
    }

    mutating func insert(_ candidate: RankedMapCandidate, cell: Int?) {
        overall.insert(candidate)
        if let cell { cells[cell].insert(candidate) }
    }

    var candidates: [MapCandidate] {
        let ranked = overall.ranked
        var seen: Set<String> = []
        var result: [RankedMapCandidate] = []
        let reserved = ranked.filter(\.selected) + cells.flatMap(\.ranked)
        for candidate in reserved + ranked where result.count < limit {
            if seen.insert(candidate.id).inserted { result.append(candidate) }
        }
        return result.sorted(by: RankedMapCandidate.precedes).map(\.candidate)
    }
}

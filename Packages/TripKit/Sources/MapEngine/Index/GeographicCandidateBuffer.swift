/// Keep the worst retained candidate at the root; storage is bounded by the projection budget.
nonisolated struct GeographicCandidateBuffer {
    private var values: [RankedMapCandidate] = []
    private var positions: [String: Int] = [:]
    let limit: Int

    init(limit: Int) { self.limit = max(0, limit) }

    var candidates: [MapCandidate] { values.sorted(by: RankedMapCandidate.precedes).map(\.candidate) }

    mutating func insert(_ value: RankedMapCandidate) {
        guard limit > 0 else { return }
        if let index = positions[value.id] {
            guard RankedMapCandidate.precedes(value, values[index]) else { return }
            values[index] = value
            sink(from: index)
        } else if values.count < limit {
            positions[value.id] = values.count
            values.append(value)
            rise(from: values.count - 1)
        } else if RankedMapCandidate.precedes(value, values[0]) {
            positions.removeValue(forKey: values[0].id)
            values[0] = value
            positions[value.id] = 0
            sink(from: 0)
        }
    }

    private mutating func rise(from index: Int) {
        var child = index
        while child > 0 {
            let parent = (child - 1) / 2
            guard RankedMapCandidate.precedes(values[parent], values[child]) else { return }
            exchange(parent, child)
            child = parent
        }
    }

    private mutating func sink(from index: Int) {
        var parent = index
        while parent * 2 + 1 < values.count {
            var child = parent * 2 + 1
            let right = child + 1
            if right < values.count, RankedMapCandidate.precedes(values[child], values[right]) { child = right }
            guard RankedMapCandidate.precedes(values[parent], values[child]) else { return }
            exchange(parent, child)
            parent = child
        }
    }

    private mutating func exchange(_ first: Int, _ second: Int) {
        values.swapAt(first, second)
        positions[values[first].id] = first
        positions[values[second].id] = second
    }
}

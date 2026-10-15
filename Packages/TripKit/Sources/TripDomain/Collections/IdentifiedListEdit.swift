import Foundation

/// Resolves visible row positions once, then applies the user's intent to current values.
public nonisolated enum IdentifiedListEdit<ID: Hashable & Sendable>: Sendable {
    case remove(Set<ID>)
    case move([ID], following: [ID])

    public static func removing(_ offsets: IndexSet, from snapshot: [ID]) -> Self? {
        guard valid(offsets, in: snapshot) else { return nil }
        return .remove(Set(offsets.map { snapshot[$0] }))
    }

    public static func moving(_ offsets: IndexSet, to destination: Int, in snapshot: [ID]) -> Self? {
        guard valid(offsets, in: snapshot), (0...snapshot.count).contains(destination) else { return nil }
        let moved = offsets.map { snapshot[$0] }
        let movedIDs = Set(moved)
        return .move(moved, following: snapshot[destination...].filter { !movedIDs.contains($0) })
    }

    @discardableResult public func apply<Element: Identifiable>(to elements: inout [Element]) -> Bool where Element.ID == ID {
        switch self {
        case .remove(let ids):
            let count = elements.count
            elements.removeAll { ids.contains($0.id) }
            return count != elements.count
        case .move(let ids, let following):
            return move(ids, before: following, in: &elements)
        }
    }

    private static func valid(_ offsets: IndexSet, in snapshot: [ID]) -> Bool {
        !offsets.isEmpty && offsets.allSatisfy(snapshot.indices.contains) && Set(snapshot).count == snapshot.count
    }

    private func move<Element: Identifiable>(_ ids: [ID], before following: [ID],
                                             in elements: inout [Element]) -> Bool where Element.ID == ID {
        let previous = elements.map(\.id)
        guard Set(previous).count == previous.count, Set(ids).count == ids.count else { return false }
        let lookup = Dictionary(uniqueKeysWithValues: elements.map { ($0.id, $0) })
        let moved = ids.compactMap { lookup[$0] }
        guard !moved.isEmpty else { return false }
        let movedIDs = Set(ids)
        var remaining = elements.filter { !movedIDs.contains($0.id) }
        let anchor = following.first { lookup[$0] != nil && !movedIDs.contains($0) }
        let insertion = anchor.flatMap { id in remaining.firstIndex { $0.id == id } } ?? remaining.endIndex
        remaining.insert(contentsOf: moved, at: insertion)
        guard remaining.map(\.id) != previous else { return false }
        elements = remaining
        return true
    }
}

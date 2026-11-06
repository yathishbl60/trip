import Foundation

enum PlaceCollectionChecks {
    static func run() throws {
        try nearestBranch()
        try tiedBranches()
        try exactIdentity()
        try separateBranches()
    }

    static func cancellation() async throws {
        let task = Task {
            await Task.yield()
            var collection = PlaceCollection([CheckFixtures.place("existing")])
            return try collection.merge([])
        }
        task.cancel()
        do {
            _ = try await task.value
            throw CheckFailure(description: "Cancelled empty catalog merge was accepted")
        } catch is CancellationError { }
    }

    private static func nearestBranch() throws {
        let distant = CheckFixtures.place("a-distant", name: "Central Hotel", longitude: 100.5)
        let nearby = CheckFixtures.place("z-nearby", name: "Central Hotel", longitude: 100.501)
        let refreshed = CheckFixtures.place("provider-new", name: "Central Hotel", longitude: 100.50101)
        for existing in [[distant, nearby], [nearby, distant]] {
            var collection = PlaceCollection(existing)
            let result = try collection.merge([refreshed])
            try require(result.count == 2, "Nearby refresh removed a separate branch")
            try require(result.first(where: { $0.id == distant.id })?.coordinate == distant.coordinate,
                        "Name matching moved a different branch's annotation")
            try require(collection.matchingPlaces.map(\.id) == [nearby.id], "Refresh did not preserve the closest identity")
        }
    }

    private static func tiedBranches() throws {
        let first = CheckFixtures.place("a", name: "Hotel")
        let second = CheckFixtures.place("b", name: "Hotel")
        for existing in [[first, second], [second, first]] {
            var collection = PlaceCollection(existing)
            _ = try collection.merge([CheckFixtures.place("provider-new", name: "Hotel")])
            try require(collection.matchingPlaces.map(\.id) == [first.id], "Equal-distance name matches changed identity")
        }
    }

    private static func exactIdentity() throws {
        let exact = CheckFixtures.place("exact", name: "Hotel", longitude: 100.5)
        let nearby = CheckFixtures.place("nearby", name: "Hotel", longitude: 100.501)
        let refreshed = CheckFixtures.place("exact", name: "Hotel", longitude: 100.50101)
        var collection = PlaceCollection([exact, nearby])
        _ = try collection.merge([refreshed])
        try require(collection.matchingPlaces.map(\.id) == [exact.id], "Proximity overrode exact provider identity")
    }

    private static func separateBranches() throws {
        let original = CheckFixtures.place("a", name: "Hotel")
        let separate = CheckFixtures.place("b", name: "Hotel", longitude: 100.51)
        var collection = PlaceCollection([original])
        let result = try collection.merge([separate])
        try require(result.count == 2, "Name match exceeded the configured radius")
    }
}

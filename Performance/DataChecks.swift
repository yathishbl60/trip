import Foundation

enum DataChecks {
    static func merging() throws {
        var collection = PlaceCollection([CheckFixtures.place("seed", name: "Cafe 1")])
        let merged = try collection.merge([CheckFixtures.place("live", name: "Cafe 1"),
                                           CheckFixtures.place("two", name: "Cafe 2")])
        try require(Set(merged.map(\.id)) == ["seed", "two"], "Nearby matching lost identity or name digits")
        var incoming = PlaceCollection([])
        let duplicates = try incoming.merge([CheckFixtures.place("a", name: "Hotel"), CheckFixtures.place("b", name: "Hotel")])
        try require(duplicates.count == 1, "Duplicate incoming names were retained")
        var bounded = PlaceCollection((0..<2_100).map { CheckFixtures.place("old-\($0)") }, preserving: "old-2099")
        let capped = try bounded.merge([CheckFixtures.place("new")])
        try require(capped.count == 2_000, "Collection cap failed")
        try require(capped.contains { $0.id == "new" } && capped.contains { $0.id == "old-2099" }, "Required identity evicted")
    }

    static func identity() throws {
        try PlaceCollectionChecks.run()
        var collection = PlaceCollection([], policy: MapDataPolicy(nameMatchRadius: nil))
        let result = try collection.merge([CheckFixtures.place("a", name: "Same"), CheckFixtures.place("b", name: "Same")])
        try require(result.count == 2, "Identity-only policy merged distinct records")
    }

    static func policies() throws {
        let policy = MarkerLayoutPolicy(markerLimit: -1, candidateLimit: -10, photoArea: .nan,
                                        interval: .seconds(-1), zoomHysteresis: .nan, appearances: [.district: []])
        try require(policy.markerLimit == 1 && policy.candidateLimit == 1, "Invalid limits not clamped")
        try require(policy.interval == .milliseconds(16) && policy.styles(at: .district) == [.dot], "Policy fallback missing")
        let motion = MapMotion(morph: .nan, fade: -1, camera: .infinity, selection: 100)
        try require(motion.morph.isFinite && motion.fade == 0 && motion.selection == 2, "Invalid motion not clamped")
        let data = MapDataPolicy(placeLimit: -1, cacheLimit: -1, nameMatchRadius: .nan)
        try require(data.placeLimit == 1 && data.cacheLimit == 0 && data.nameMatchRadius == nil, "Invalid data policy")
    }
}

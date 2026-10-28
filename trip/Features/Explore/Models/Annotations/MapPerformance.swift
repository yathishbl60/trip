import os

/// Points of Interest expose the remaining main-actor work in device Instruments traces.
nonisolated enum MapPerformance {
    private static let signposter = OSSignposter(subsystem: "com.trip.map", category: .pointsOfInterest)

    static func measure<Value>(_ name: StaticString, operation: () -> Value) -> Value {
        let interval = begin(name)
        defer { end(name, interval) }
        return operation()
    }

    static func begin(_ name: StaticString) -> OSSignpostIntervalState {
        signposter.beginInterval(name, id: signposter.makeSignpostID())
    }

    static func end(_ name: StaticString, _ interval: OSSignpostIntervalState) {
        signposter.endInterval(name, interval)
    }
}

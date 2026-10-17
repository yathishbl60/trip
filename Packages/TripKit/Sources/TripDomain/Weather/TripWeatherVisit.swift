import Foundation

public nonisolated struct TripWeatherVisit: Identifiable, Sendable {
    public var id: UUID { target.id }
    public let target: TripWeatherTarget
    public let hour: TripWeatherHour?
    public let didFail: Bool

    public init(target: TripWeatherTarget, hour: TripWeatherHour?, didFail: Bool = false) {
        self.target = target
        self.hour = hour
        self.didFail = didFail
    }
}

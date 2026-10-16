import Foundation

public nonisolated struct TripTimelineEntry: Identifiable, Sendable {
    public let id: UUID
    public let day: Date
    public let arrival: Date
    public let departure: Date
    public let fixedArrival: Date?
    public let visitMinutes: Int
    public let travelMinutes: Int
    public let bufferMinutes: Int
    public let waitingMinutes: Int
    public var timeZoneID: String? = nil
    public var arrivalIssue: String? = nil

    public var lateMinutes: Int {
        guard let fixedArrival else { return 0 }
        return max(0, Int(ceil(arrival.timeIntervalSince(fixedArrival) / 60)))
    }
}

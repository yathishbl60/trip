import Foundation

/// Explicit edits to one saved visit; omitted values preserve the current timing.
public nonisolated struct TripVisitTimingChange: Sendable {
    public var visitMinutes: Int?
    public var travelMinutes: Int?
    public var bufferMinutes: Int?
    public var arrivalTime: String?
    public var nextDay: Bool
    public var flexibleArrival: Bool

    public init(visitMinutes: Int? = nil, travelMinutes: Int? = nil, bufferMinutes: Int? = nil,
                arrivalTime: String? = nil, nextDay: Bool = false, flexibleArrival: Bool = false) {
        self.visitMinutes = visitMinutes
        self.travelMinutes = travelMinutes
        self.bufferMinutes = bufferMinutes
        self.arrivalTime = arrivalTime
        self.nextDay = nextDay
        self.flexibleArrival = flexibleArrival
    }

    @discardableResult public func apply(to plan: inout TripPlan, stopID: UUID) throws -> Bool {
        for dayIndex in plan.days.indices {
            guard let stopIndex = plan.days[dayIndex].stops.firstIndex(where: { $0.id == stopID }) else { continue }
            let current = plan.days[dayIndex].stops[stopIndex].timing
            let timing = try value(from: current, on: plan.date(for: plan.days[dayIndex]), calendar: plan.calendar)
            guard current != timing else { return false }
            plan.days[dayIndex].stops[stopIndex].timing = timing
            return true
        }
        throw TripVisitTimingError.missingVisit
    }

    private func value(from current: TripStopTiming, on date: Date, calendar: Calendar) throws -> TripStopTiming {
        try validate()
        var timing = current
        timing.visitMinutes = visitMinutes ?? timing.visitMinutes
        timing.travelMinutes = travelMinutes ?? timing.travelMinutes
        timing.bufferMinutes = bufferMinutes ?? timing.bufferMinutes
        if let arrivalTime {
            timing.arrivalMinute = try minute(arrivalTime) + (nextDay ? 1440 : 0)
            timing.arrivalOccurrence = .unresolved
        } else if flexibleArrival {
            timing.arrivalMinute = nil
            timing.arrivalOccurrence = .unresolved
        }
        if arrivalTime != nil, timing.arrivalClock(on: date, calendar: calendar)?.issue != nil {
            throw TripVisitTimingError.clockNeedsReview
        }
        return timing
    }

    private func validate() throws {
        guard visitMinutes != nil || travelMinutes != nil || bufferMinutes != nil || arrivalTime != nil || flexibleArrival else {
            throw TripVisitTimingError.emptyChange
        }
        guard visitMinutes.map(TripLimits.visitMinutes.contains) ?? true,
              travelMinutes.map(TripLimits.travelMinutes.contains) ?? true,
              bufferMinutes.map(TripLimits.bufferMinutes.contains) ?? true else { throw TripVisitTimingError.invalidMinutes }
        guard !(flexibleArrival && arrivalTime != nil), !nextDay || arrivalTime != nil else {
            throw TripVisitTimingError.conflictingArrival
        }
    }

    private func minute(_ text: String) throws -> Int {
        let parts = text.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count == 2, parts.allSatisfy({ $0.utf8.count == 2 && $0.utf8.allSatisfy { (48...57).contains($0) } }),
              let hour = Int(parts[0]), let minute = Int(parts[1]),
              (0...23).contains(hour), (0...59).contains(minute) else { throw TripVisitTimingError.invalidArrival }
        return hour * 60 + minute
    }
}

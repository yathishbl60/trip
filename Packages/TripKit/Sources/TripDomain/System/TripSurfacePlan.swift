import Foundation

public nonisolated struct TripSurfacePlan: Codable, Equatable, Sendable, Identifiable {
    public let id: UUID
    public let title: String
    public let days: [TripSurfaceDay]
    public let startDate: Date
    public var checklistProgress: TripChecklistProgress? = nil
    public var endDate: Date { days.last?.date ?? startDate }

    public init(_ plan: TripPlan) {
        id = plan.id
        title = String(plan.title.prefix(TripLimits.titleCharacters))
        startDate = plan.startDate
        checklistProgress = TripChecklistProgress(plan)
        days = plan.days.prefix(TripLimits.days).map {
            TripSurfaceDay($0, date: plan.date(for: $0), items: TripSurfaceAgenda.items(in: plan, day: $0), zoneID: plan.timeZoneID)
        }
    }

    public init(id: UUID, title: String, startDate: Date, days: [TripSurfaceDay]) {
        self.id = id
        self.title = String(title.prefix(TripLimits.titleCharacters))
        self.startDate = startDate
        self.days = Array(days.prefix(TripLimits.days))
    }

    public func day(at date: Date) -> TripSurfaceDay? {
        days.first { $0.calendar.isDate($0.date, inSameDayAs: date) }
            ?? days.first { $0.date > date }
    }
}

public nonisolated struct TripSurfaceDay: Codable, Equatable, Sendable, Identifiable {
    public let id: UUID
    public let number: Int
    public let date: Date
    public let stops: [TripSurfaceStop]
    public let items: [TripSurfaceItem]?
    public let zoneID: String?
    public var calendar: Calendar { TripLocalDate.calendar(zoneID: zoneID ?? TimeZone.current.identifier) }
    public var dateText: String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, timeZone: calendar.timeZone))
    }
    public var agenda: [TripSurfaceItem] { items ?? stops.map(TripSurfaceItem.init) }

    public init(_ day: TripDay, date: Date, items: [TripSurfaceItem]? = nil, zoneID: String? = nil) {
        id = day.id
        number = day.number
        self.date = date
        stops = day.stops.prefix(TripLimits.stops).map(TripSurfaceStop.init)
        self.items = items
        self.zoneID = zoneID
    }

    public init(id: UUID, number: Int, date: Date, stops: [TripSurfaceStop], items: [TripSurfaceItem]? = nil, zoneID: String? = nil) {
        self.id = id
        self.number = number
        self.date = date
        self.stops = Array(stops.prefix(TripLimits.stops))
        self.items = items
        self.zoneID = zoneID
    }
}

public nonisolated struct TripSurfaceStop: Codable, Equatable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let category: PlaceCategory
    public let coordinate: Coordinate
    // Older shared snapshots have no saved timing values.
    public let visitMinutes: Int?
    public let travelMinutes: Int?
    public let bufferMinutes: Int?

    public init(_ stop: TripStop) {
        id = stop.id
        name = String(stop.place.name.prefix(96))
        category = stop.place.category
        coordinate = stop.place.coordinate
        visitMinutes = stop.timing.visitMinutes
        travelMinutes = stop.timing.travelMinutes
        bufferMinutes = stop.timing.bufferMinutes
    }

    public init(id: UUID, name: String, category: PlaceCategory, coordinate: Coordinate,
                visitMinutes: Int? = nil, travelMinutes: Int? = nil, bufferMinutes: Int? = nil) {
        self.id = id
        self.name = String(name.prefix(96))
        self.category = category
        self.coordinate = coordinate
        self.visitMinutes = visitMinutes
        self.travelMinutes = travelMinutes
        self.bufferMinutes = bufferMinutes
    }
}

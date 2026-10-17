import Foundation

nonisolated extension TripSurfaceAgenda {
    public static func prioritized(in day: TripSurfaceDay, at date: Date, excluding visited: Set<UUID> = []) -> [TripSurfaceItem] {
        upcoming(in: day, at: date).enumerated().filter { !visited.contains($0.element.id) }.sorted {
            let first = priority($0.element, day: day, at: date)
            let second = priority($1.element, day: day, at: date)
            return first == second ? $0.offset < $1.offset : first < second
        }.map(\.element)
    }

    private static func priority(_ item: TripSurfaceItem, day: TripSurfaceDay, at date: Date) -> (Int, Date) {
        if item.requiresTimeReview == true { return (1, .distantFuture) }
        if item.kind == .stay, let start = item.startsAt, start < date {
            if let end = item.endsAt, day.calendar.isDate(end, inSameDayAs: date) { return (0, end) }
            return (2, item.endsAt ?? .distantFuture)
        }
        if let time = item.startsAt ?? item.endsAt { return (0, time) }
        return (1, .distantFuture)
    }

    public static func nextChange(in day: TripSurfaceDay, after date: Date) -> Date? {
        day.agenda.filter { $0.requiresTimeReview != true }.flatMap { [$0.startsAt, $0.endsAt].compactMap { $0 } }
            .filter { $0 > date }.min()
    }
}

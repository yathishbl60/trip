import Foundation

extension TripDayBriefing {
    public nonisolated var previousDate: Date? { adjacentDate(offset: -1) }
    public nonisolated var nextDate: Date? { adjacentDate(offset: 1) }

    private nonisolated func adjacentDate(offset: Int) -> Date? {
        guard let day, let index = plan.days.firstIndex(where: { $0.id == day.id }),
              plan.days.indices.contains(index + offset) else { return nil }
        return plan.days[index + offset].date
    }
}

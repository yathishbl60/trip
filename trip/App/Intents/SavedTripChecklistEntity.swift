import AppIntents
import Foundation
import TripDomain

struct SavedTripChecklistEntity: AppEntity, Sendable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "trip_checklist_item") }
    static var defaultQuery: SavedTripChecklistQuery { SavedTripChecklistQuery() }
    let id: String
    @Property(title: "title") var title: String
    @Property(title: "trip") var tripName: String
    @Property(title: "complete") var isComplete: Bool

    init(_ item: TripChecklistItem, plan: TripPlan) {
        id = TripChecklistIdentity(tripID: plan.id, itemID: item.id).rawValue
        title = item.title
        tripName = plan.title
        isComplete = item.isComplete
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "\(tripName)",
                              image: .init(systemName: isComplete ? "checkmark.circle.fill" : "circle"))
    }
}

nonisolated struct SavedTripChecklistQuery: EntityStringQuery {
    static var allowedExecutionTargets: IntentExecutionTargets { .main }

    @MainActor func entities(for identifiers: [String]) async throws -> [SavedTripChecklistEntity] {
        let library = try await AppRuntime.library()
        return identifiers.compactMap { rawValue in
            guard let identity = TripChecklistIdentity(rawValue), let plan = library.trip(identity.tripID),
                  let item = identity.resolve(in: plan) else { return nil }
            return SavedTripChecklistEntity(item, plan: plan)
        }
    }

    @MainActor func entities(matching string: String) async throws -> [SavedTripChecklistEntity] {
        let plans = try await AppRuntime.library().trips
        let query = PlaceSearchQuery(string)
        return plans.flatMap { plan in
            plan.checklist.filter { query.matches([$0.title, plan.title]) }
                .map { SavedTripChecklistEntity($0, plan: plan) }
        }.prefix(100).map { $0 }
    }

    @MainActor func suggestedEntities() async throws -> [SavedTripChecklistEntity] {
        let plans = try await AppRuntime.library().trips
        return plans.filter(isUpcoming).prefix(10).flatMap { plan in
            plan.checklist.filter { !$0.isComplete }.prefix(10).map { SavedTripChecklistEntity($0, plan: plan) }
        }
    }

    private func isUpcoming(_ plan: TripPlan) -> Bool {
        let end = plan.days.last.map { plan.date(for: $0) } ?? plan.startDate
        return end >= plan.calendar.startOfDay(for: .now)
    }
}

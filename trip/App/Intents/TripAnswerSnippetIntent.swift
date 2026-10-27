import AppIntents
import Foundation
import SwiftUI
import TripDomain

struct TripAnswerSnippetIntent: SnippetIntent {
    static var title: LocalizedStringResource { "intent_saved_trip_answer" }
    static var isDiscoverable: Bool { false }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip_identifier") var tripIdentifier: String
    @Parameter(title: "filter") var category: String
    @Parameter(title: "day_identifier") var dayIdentifier: String
    @Parameter(title: "name_or_location") var search: String

    init() {}
    init(answer: TripDetailAnswer) {
        tripIdentifier = answer.plan.id.uuidString
        category = answer.query.category.rawValue
        dayIdentifier = answer.plan.days.first { $0.number == answer.query.dayNumber }?.id.uuidString ?? ""
        search = answer.query.searchText
    }

    @MainActor func perform() async throws -> some IntentResult & ShowsSnippetView {
        guard let id = UUID(uuidString: tripIdentifier) else { throw TripIntentError.missingTrip }
        let plan = TripSurfacePlan(try await AppRuntime.trip(id))
        let day = plan.days.first { $0.id.uuidString == dayIdentifier }
        guard let kind = TripDetailCategory(rawValue: category),
              dayIdentifier.isEmpty || day != nil else { throw TripIntentError.missingDay }
        let query = TripDetailQuery(category: kind, dayNumber: day?.number, searchText: search)
        return .result(view: TripAnswerView(answer: TripDetailAnswer(plan: plan, query: query)))
    }
}

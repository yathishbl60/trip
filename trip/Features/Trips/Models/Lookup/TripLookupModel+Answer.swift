import Foundation
import TripDomain

extension TripLookupModel {
    func interpret(_ question: String, plan: TripSurfacePlan, now: Date = .now) async throws -> TripDetailQuery {
        let interpreter = client.makeService(processing)
        do {
            return try await interpreter.interpret(question, days: plan.days, now: now)
        } catch {
            try Task.checkCancellation()
            throw TripLookupFailure(message: failureMessage(error))
        }
    }
}

nonisolated struct TripLookupFailure: LocalizedError, CustomLocalizedStringResourceConvertible {
    let message: String
    var errorDescription: String? { message }
    var localizedStringResource: LocalizedStringResource { "\(message)" }
}

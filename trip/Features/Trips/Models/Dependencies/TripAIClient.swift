import TripDomain

/// A workflow's service factory and presentation policy, supplied by its host.
/// Availability and errors are injectable so previews need no model download.
@MainActor struct TripAIClient<Service: Sendable> {
    let makeService: (TripAIProcessing) -> Service
    let availability: (TripAIProcessing) -> String?
    let failureMessage: (Error) -> String
}

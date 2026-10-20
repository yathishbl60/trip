#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation
import FoundationModels
import TripDomain

nonisolated enum TripAISession {
    static func make(processing: TripAIProcessing, instructions: String) async throws -> LanguageModelSession {
        try Task.checkCancellation()
        if let issue = TripAIAvailability.issue(for: processing) { throw TripAIError.unavailable(issue) }
        if processing == .privateCloudCompute { return try await cloud(instructions) }
        let model = SystemLanguageModel.default
        guard model.supportsLocale(.current) else { throw TripAIError.unsupportedLanguage }
        guard model.capabilities.contains(.guidedGeneration) else { throw TripAIError.unsupportedCapability }
        return LanguageModelSession(model: model, instructions: instructions)
    }

    private static func cloud(_ instructions: String) async throws -> LanguageModelSession {
        let model = PrivateCloudComputeLanguageModel()
        guard try await model.supportsLocale(.current) else { throw TripAIError.unsupportedLanguage }
        guard model.capabilities.contains(.guidedGeneration) else { throw TripAIError.unsupportedCapability }
        try Task.checkCancellation()
        return LanguageModelSession(model: model, instructions: instructions)
    }
}

public nonisolated enum TripAIError: LocalizedError {
    case unavailable(String), unsupportedLanguage, unsupportedCapability, requestTimedOut

    public var errorDescription: String? {
        switch self {
        case .unavailable(let message): message
        case .unsupportedLanguage: TripText.theSelectedAiModelDoesnTSupportThisLanguage.text
        case .unsupportedCapability: TripText.theSelectedModelDoesnTSupportStructuredTripRequests.text
        case .requestTimedOut: TripText.thatTookTooLongTryAShorterQuestionOr.text
        }
    }
}

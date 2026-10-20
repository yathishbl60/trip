import TripLocalization
import Foundation
import FoundationModels

nonisolated extension TripAIFailure {
    public static func packingMessage(for error: Error) -> String {
        if let message = TripAIFailure.message(for: error) { return message }
        if let error = error as? TripPackingError { return error.localizedDescription }
        if error is SystemLanguageModel.Error { return TripText.appleIntelligenceIsnTReadyTryAgainOrAdd.text }
        guard let error = error as? LanguageModelError else {
            return TripText.couldnTCreateAPackingListTryAgainOr.text
        }
        switch error {
        case .unsupportedLanguageOrLocale: return TripText.appleIntelligenceDoesnTSupportThisLanguageTravelEssentials.text
        case .contextSizeExceeded: return TripText.shortenYourPackingPreferenceAndTryAgain.text
        case .rateLimited: return TripText.appleIntelligenceIsBusyWaitAMomentAndTry.text
        case .timeout: return TripText.packingSuggestionsTookTooLongTryAgainOrAdd.text
        case .guardrailViolation, .refusal: return TripText.tryADifferentPackingPreferenceOrAddTravelEssentials.text
        default: return TripText.couldnTCreateAPackingListTryAgainOr.text
        }
    }
}

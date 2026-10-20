import TripLocalization
import Foundation
import FoundationModels

nonisolated extension TripAIFailure {
    public static func lookupMessage(for error: Error) -> String {
        if let message = TripAIFailure.message(for: error) { return message }
        guard let failure = error as? LanguageModelError else {
            return TripText.couldnTUnderstandThatQuestionTryRephrasingItOr.text
        }
        switch failure {
        case .unsupportedLanguageOrLocale: return TripText.tryAnotherLanguageOrBrowseUsingQuickFilters.text
        case .rateLimited: return TripText.appleIntelligenceIsBusyTryAgainShortlyOrUse.text
        case .contextSizeExceeded: return TripText.tryAShorterQuestionOrBrowseUsingQuickFilters.text
        case .timeout: return TripText.thatTookTooLongTryAgainOrUseA.text
        case .guardrailViolation, .refusal: return TripText.tryAskingAboutASavedPlaceStayFlightOr.text
        default: return TripText.couldnTFindThoseDetailsTryRephrasingYourQuestion.text
        }
    }
}

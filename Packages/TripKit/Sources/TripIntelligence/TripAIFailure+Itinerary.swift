import TripLocalization
import Foundation
import FoundationModels

nonisolated extension TripAIFailure {
    public static func itineraryMessage(for error: Error) -> String {
        if let message = TripAIFailure.message(for: error) { return message }
        if error is SystemLanguageModel.Error {
            return TripText.appleIntelligenceIsnTReadyYetTryAgainShortly.text
        }
        guard let failure = error as? LanguageModelError else {
            return TripText.couldnTCreateADraftTryAgainOrPlan.text
        }
        switch failure {
        case .contextSizeExceeded: return TripText.chooseFewerPlacesOrShortenYourPreferencesThenTry.text
        case .unsupportedLanguageOrLocale: return TripText.thisLanguageIsnTSupportedByAppleIntelligenceTry.text
        case .rateLimited: return TripText.appleIntelligenceIsBusyWaitAMomentAndTry.text
        case .timeout: return TripText.theDraftTookTooLongTryAgainWithFewer.text
        case .guardrailViolation, .refusal: return TripText.changeYourPreferencesOrPlanManually.text
        default: return TripText.couldnTCreateADraftTryAgainOrPlan.text
        }
    }
}

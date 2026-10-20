#if !TRIP_STANDALONE
import TripLocalization
#endif
import FoundationModels
import TripDomain

public nonisolated enum TripAIAvailability {
    public static func issue(for processing: TripAIProcessing) -> String? {
        processing == .onDevice ? onDeviceIssue : cloudIssue
    }

    private static var onDeviceIssue: String? {
        switch SystemLanguageModel.default.availability {
        case .available: nil
        case .unavailable(.appleIntelligenceNotEnabled): TripText.turnOnAppleIntelligenceInSettingsToUseOn.text
        case .unavailable(.modelNotReady): TripText.theOnDeviceModelIsGettingReadyTryAgain.text
        case .unavailable(.deviceNotEligible): TripText.onDeviceAppleIntelligenceIsnTSupportedOnThis.text
        default: TripText.onDeviceAIUnavailable.text
        }
    }

    private static var cloudIssue: String? {
        let model = PrivateCloudComputeLanguageModel()
        switch model.availability {
        case .available:
            return model.quotaUsage.isLimitReached ? TripText.privateCloudComputeSUsageLimitHasBeenReached.text : nil
        case .unavailable(.deviceNotEligible): return TripText.privateCloudComputeIsnTSupportedOnThisDevice.text
        case .unavailable(.systemNotReady): return TripText.privateCloudComputeIsnTReadyTryAgainLater.text
        default: return TripText.privateCloudComputeIsUnavailable.text
        }
    }
}

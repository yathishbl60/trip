#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation
import FoundationModels

public nonisolated enum TripAIFailure {
    public static func message(for error: Error) -> String? {
        if let error = error as? TripAIError { return error.errorDescription }
        guard let cloud = error as? PrivateCloudComputeLanguageModel.Error else { return nil }
        switch cloud {
        case .networkFailure: return TripText.couldnTConnectToPrivateCloudComputeCheckYour.text
        case .serviceUnavailable: return TripText.privateCloudComputeIsTemporarilyUnavailableTryAgainLater.text
        case .quotaLimitReached(let context):
            guard let reset = context.resetDate else { return TripText.privateCloudComputeSUsageLimitHasBeenReached.text }
            return TripText.privateCloudComputeSUsageLimitResetsValue(reset.formatted(date: .abbreviated, time: .shortened)).text
        @unknown default: return TripText.privateCloudComputeCouldnTFinishThisRequestTry.text
        }
    }
}

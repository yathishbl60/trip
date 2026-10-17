#if !TRIP_STANDALONE
import TripLocalization
#endif
/// Inference location is an explicit choice, never an automatic fallback.
public nonisolated enum TripAIProcessing: String, CaseIterable, Sendable, Identifiable {
    case onDevice, privateCloudCompute

    public var id: String { rawValue }
    public var title: String { self == .onDevice ? TripText.onDevice.text : TripText.privateCloudCompute.text }
    public var lookupExplanation: String {
        switch self {
        case .onDevice: TripText.questionsAreProcessedOnThisDeviceQuickFiltersWork.text
        case .privateCloudCompute:
            TripText.yourQuestionAndTripDatesAreSentToApple.text
        }
    }
    public var planningExplanation: String {
        switch self {
        case .onDevice: TripText.yourSavedPlacesAndPreferencesAreProcessedOnThis.text
        case .privateCloudCompute:
            TripText.selectedPlaceNamesCategoriesCoordinatesAndPreferencesAreSent.text
        }
    }
}

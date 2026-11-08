#if os(iOS)
import AppIntents
import TripDomain

@AppIntent(.tool)
struct ReviewSavedTripBookingAlarmIntent {
    static var title: LocalizedStringResource { "intent_review_booking_alarm" }
    static var description: IntentDescription { IntentDescription("intent_review_booking_alarm_description") }
    static var supportedModes: IntentModes { .foreground }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "detail", description: "intent_parameter_alarm_booking") var booking: SavedTripDetailEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Review the alarm for \(\ReviewSavedTripBookingAlarmIntent.$booking as KeyPath<ReviewSavedTripBookingAlarmIntent, Parameter<SavedTripDetailEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult {
        guard let identity = TripDetailIdentity(booking.id) else { throw TripDetailIntentError.missingDetail }
        try await AppRuntime.reviewBookingAlarm(identity)
        return .result()
    }
}
#endif

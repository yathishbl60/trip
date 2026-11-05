import AppIntents
import Foundation
import TripDomain
import TripLocalization
import UniformTypeIdentifiers

struct ImportTripBookingIntent: AppIntent {
    static var title: LocalizedStringResource { "intent_import_trip_booking" }
    static var description: IntentDescription { IntentDescription("intent_import_trip_booking_description") }
    static var supportedModes: IntentModes { .foreground }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "booking_document", description: "intent_parameter_booking_file", supportedContentTypes: [.pdf, .image, .plainText]) var file: IntentFile
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    @Parameter(title: "day_number", description: "intent_parameter_day_number", inclusiveRange: (1, 30)) var day: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Import \(\ImportTripBookingIntent.$file as KeyPath<ImportTripBookingIntent, Parameter<IntentFile>>) into \(\ImportTripBookingIntent.$trip as KeyPath<ImportTripBookingIntent, Parameter<SavedTripEntity>>)") {
            \ImportTripBookingIntent.$day as KeyPath<ImportTripBookingIntent, Parameter<Int>>
        }
    }

    @MainActor func perform() async throws -> some IntentResult & ProvidesDialog {
        guard AppRuntime.activeScene?.trips.hasEditingSession != true else { throw TripPlaceSearchIntentError.editing }
        let document = try await readDocument()
        try await AppRuntime.importBooking(document, tripID: trip.id, dayNumber: day)
        return .result(dialog: IntentDialog(TripText.bookingOpeningReview.resource))
    }

    private func readDocument() async throws -> TripBookingDocument {
        let types = file.availableContentTypes
        guard let type = types.first(where: { $0.conforms(to: .pdf) || $0.conforms(to: .image) || $0.conforms(to: .plainText) }) else {
            throw TripBookingImportError.unsupported
        }
        let reader = TripBookingFileLoader()
        return try await file.withFile(contentType: type) { url, _ in try await reader.read(url, contentType: type) }
    }
}

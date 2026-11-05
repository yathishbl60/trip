import Foundation
#if !TRIP_STANDALONE
import TripLocalization
#endif

public nonisolated enum TripBookingImportError: LocalizedError, CustomLocalizedStringResourceConvertible, Sendable {
    case fileTooLarge, documentTooLong, unsupported, unreadable, lockedPDF, noText

    public var errorDescription: String? { String(localized: localizedStringResource) }

    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .fileTooLarge: TripText.bookingFileTooLarge.resource
        case .documentTooLong: TripText.bookingDocumentTooLong.resource
        case .unsupported: TripText.bookingUnsupportedFile.resource
        case .unreadable: TripText.bookingUnreadableFile.resource
        case .lockedPDF: TripText.bookingLockedPDF.resource
        case .noText: TripText.bookingNoReadableText.resource
        }
    }
}

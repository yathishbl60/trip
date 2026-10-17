import Foundation
#if !TRIP_STANDALONE
import TripLocalization
#endif

public nonisolated enum TripBookingImportError: Error, LocalizedError, Sendable {
    case fileTooLarge, documentTooLong, unsupported, unreadable, lockedPDF, noText

    public var errorDescription: String? {
        switch self {
        case .fileTooLarge: TripText.bookingFileTooLarge.text
        case .documentTooLong: TripText.bookingDocumentTooLong.text
        case .unsupported: TripText.bookingUnsupportedFile.text
        case .unreadable: TripText.bookingUnreadableFile.text
        case .lockedPDF: TripText.bookingLockedPDF.text
        case .noText: TripText.bookingNoReadableText.text
        }
    }
}

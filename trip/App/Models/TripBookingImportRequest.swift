import Foundation
import TripDomain

/// Only the request identity participates in navigation equality; document bytes stay ephemeral.
nonisolated struct TripBookingImportRequest: Hashable {
    let id = UUID()
    let tripID: UUID
    let dayID: UUID
    let document: TripBookingDocument

    init(tripID: UUID, dayID: UUID, document: TripBookingDocument) throws {
        guard document.data.count <= TripBookingLimits.maximumFileBytes else { throw TripBookingImportError.fileTooLarge }
        self.tripID = tripID
        self.dayID = dayID
        self.document = document
    }

    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

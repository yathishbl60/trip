#if DEBUG
import Foundation
import TripDomain

enum TripBookingPreview {
    static let proposal = TripBookingProposal(sourceName: "Sample hotel confirmation.pdf",
        recognizedText: "Sample Riverside Hotel\nCheck-in: 2026-11-03 15:00\nCheck-out: 2026-11-05 11:00",
        suggestedTitle: "Sample Riverside Hotel", suggestedKind: .stay,
        dates: [TripBookingDateCandidate(id: 0, sourceText: "2026-11-03 15:00",
                                        date: TripLocalDate(year: 2026, month: 11, day: 3), minute: 900)])

    static func model() -> TripBookingImportModel {
        let model = TripBookingImportModel(reader: PreviewBookingReader())
        let trip = TripJourneyPreview.planner().library.trips[0]
        model.begin(trip: trip, dayID: trip.days[0].id)
        model.accept(proposal)
        return model
    }
}

struct PreviewBookingReader: TripBookingReading {
    nonisolated func read(_ document: TripBookingDocument) async throws -> TripBookingProposal {
        try Task.checkCancellation()
        return TripBookingProposal(sourceName: document.filename, recognizedText: "Sample booking",
                                   suggestedTitle: "Sample booking", suggestedKind: .reservation)
    }
}
#endif

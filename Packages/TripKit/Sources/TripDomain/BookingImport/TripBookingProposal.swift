import Foundation

/// Suggestions require review. OCR text is evidence, not a verified booking record.
public nonisolated struct TripBookingProposal: Sendable {
    public let sourceName: String
    public let recognizedText: String
    public let suggestedTitle: String
    public let suggestedKind: TripEventKind
    public let suggestedLocation: String
    public let suggestedArrivalLocation: String
    public let dates: [TripBookingDateCandidate]

    public init(sourceName: String, recognizedText: String, suggestedTitle: String,
                suggestedKind: TripEventKind, suggestedLocation: String = "", suggestedArrivalLocation: String = "",
                dates: [TripBookingDateCandidate] = []) {
        self.sourceName = sourceName
        self.recognizedText = recognizedText
        self.suggestedTitle = suggestedTitle
        self.suggestedKind = suggestedKind
        self.suggestedLocation = suggestedLocation
        self.suggestedArrivalLocation = suggestedArrivalLocation
        self.dates = dates
    }
}

public nonisolated struct TripBookingDateCandidate: Identifiable, Sendable {
    public let id: Int
    public let sourceText: String
    public let date: TripLocalDate
    public let minute: Int

    public init(id: Int, sourceText: String, date: TripLocalDate, minute: Int) {
        self.id = id
        self.sourceText = sourceText
        self.date = date
        self.minute = minute
    }

    public func clock(zoneID: String) -> TripZonedDateTime {
        TripZonedDateTime(date: date, minute: minute, zoneID: zoneID)
    }
}

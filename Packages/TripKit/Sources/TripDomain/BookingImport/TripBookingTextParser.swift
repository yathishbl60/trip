import Foundation

/// Conservative local extraction: only explicit dated clocks become time suggestions.
/// Other dates remain in the evidence for manual entry; no missing year or timezone is guessed.
public nonisolated enum TripBookingTextParser {
    public static func proposal(text: String, sourceName: String) throws -> TripBookingProposal {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw TripBookingImportError.noText }
        guard text.count <= TripBookingLimits.maximumTextCharacters else { throw TripBookingImportError.documentTooLong }
        let title = text.split(whereSeparator: \.isNewline).first.map(String.init) ?? sourceName
        return TripBookingProposal(sourceName: sourceName, recognizedText: text,
                                   suggestedTitle: String(title.prefix(TripLimits.titleCharacters)),
                                   suggestedKind: kind(in: text),
                                   suggestedLocation: labeledValue(in: text, labels: ["address", "hotel address", "from", "location"]),
                                   suggestedArrivalLocation: labeledValue(in: text, labels: ["to", "destination"]),
                                   dates: TripBookingDateParser.candidates(in: text))
    }

    private static func kind(in text: String) -> TripEventKind {
        let lower = text.lowercased()
        if lower.contains("flight") || lower.contains("boarding") { return .flight }
        if lower.contains("check-in") || lower.contains("check in") || lower.contains("hotel") { return .stay }
        if lower.contains("train") || lower.contains("rail") { return .train }
        return .reservation
    }

    private static func labeledValue(in text: String, labels: Set<String>) -> String {
        for line in text.split(whereSeparator: \.isNewline) {
            let fields = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            if fields.count == 2, labels.contains(fields[0].lowercased()) {
                return String(fields[1].prefix(TripLimits.noteCharacters))
            }
        }
        return ""
    }
}

import Foundation

enum TripBookingImportChecks {
    static func run() throws {
        try meridiem()
        try offsetEvidence()
        try unsupportedDates()
        try boundedInput()
    }

    private static func meridiem() throws {
        let afternoon = ["2026-12-05 06:30 PM", "5 December 2026 06:30 PM",
                         "Dec 5, 2026 06:30 PM", "2026-12-05 06:30PM"]
        for text in afternoon {
            let proposal = try TripBookingTextParser.proposal(text: text, sourceName: "Booking")
            try require(proposal.dates.count == 1, "Dropped a complete dated afternoon clock")
            try require(proposal.dates[0].minute == 18 * 60 + 30, "Changed afternoon to morning")
            try require(proposal.dates[0].sourceText == text, "Lost the meridiem evidence")
        }
        let midnight = try TripBookingTextParser.proposal(text: "2026-12-05 12:00 AM", sourceName: "Booking")
        try require(midnight.dates.first?.minute == 0, "Changed midnight to noon")
    }

    private static func offsetEvidence() throws {
        let text = "2026-12-05T18:30:00+05:30"
        let proposal = try TripBookingTextParser.proposal(text: "Flight\n" + text, sourceName: "Boarding pass")
        try require(proposal.suggestedKind == .flight, "Lost the flight suggestion")
        try require(proposal.dates.count == 1, "Dropped an explicit ISO clock")
        try require(proposal.dates[0].minute == 18 * 60 + 30, "Silently changed the local clock")
        try require(proposal.dates[0].sourceText == text, "Discarded source offset evidence")
        let reviewed = proposal.dates[0].clock(zoneID: "Asia/Kolkata")
        try require(reviewed.zoneID == "Asia/Kolkata", "Replaced the reviewed time zone")
    }

    private static func unsupportedDates() throws {
        let text = "Hotel Example\nAddress: 10 Garden Street\n05/06/2026 15:00\nDecember 5 06:30 PM"
        let proposal = try TripBookingTextParser.proposal(text: text, sourceName: "Booking")
        try require(proposal.dates.isEmpty, "Guessed an ambiguous date or missing year")
        try require(proposal.suggestedLocation == "10 Garden Street", "Lost a labeled location")
        for invalid in ["2026-02-30 10:30", "2026-12-05 25:90", "2026-12-05 06:30 p.m."] {
            let result = try TripBookingTextParser.proposal(text: invalid, sourceName: "Booking")
            try require(result.dates.isEmpty, "Accepted an invalid or partially recognized clock")
        }
    }

    private static func boundedInput() throws {
        do {
            _ = try TripBookingTextParser.proposal(text: String(repeating: "a", count: TripBookingLimits.maximumTextCharacters + 1),
                                                  sourceName: "Booking")
            throw CheckFailure(description: "Accepted oversized extracted text")
        } catch TripBookingImportError.documentTooLong { }
        let text = Array(repeating: "2026-12-05 10:30", count: TripBookingLimits.maximumDateCandidates + 1).joined(separator: "\n")
        let proposal = try TripBookingTextParser.proposal(text: text, sourceName: "Booking")
        try require(proposal.dates.count == TripBookingLimits.maximumDateCandidates, "Did not bound the date choices")
        try require(proposal.dates.map(\.id) == proposal.dates.map(\.id).sorted(), "Changed source date ordering")
    }
}

import Foundation

/// Selected document bytes are ephemeral: readers must not publish them to system projections.
public nonisolated struct TripBookingDocument: Sendable {
    public enum Format: Sendable { case pdf, image, text }
    public let data: Data
    public let filename: String
    public let format: Format

    public init(data: Data, filename: String, format: Format) {
        self.data = data
        self.filename = filename
        self.format = format
    }
}

public nonisolated enum TripBookingLimits {
    public static let maximumFileBytes = 20 * 1_024 * 1_024
    public static let maximumPages = 12
    public static let maximumTextCharacters = 12_000
    public static let maximumImageDimension = 3_072
    public static let maximumDateCandidates = 12
}

public nonisolated protocol TripBookingReading: Sendable {
    func read(_ document: TripBookingDocument) async throws -> TripBookingProposal
}

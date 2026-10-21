import Foundation
import TripDomain
import Vision
import CoreGraphics

/// On-device document reading; no booking bytes leave this worker or enter a shared index.
public actor TripBookingReader: TripBookingReading {
    public init() {}

    public func read(_ document: TripBookingDocument) async throws -> TripBookingProposal {
        guard document.data.count <= TripBookingLimits.maximumFileBytes else { throw TripBookingImportError.fileTooLarge }
        try Task.checkCancellation()
        let text: String
        switch document.format {
        case .pdf: text = try await pdfText(document.data)
        case .image: text = try await recognize(image(from: document.data))
        case .text:
            guard let decoded = String(data: document.data, encoding: .utf8) else { throw TripBookingImportError.unreadable }
            text = decoded
        }
        try Task.checkCancellation()
        return try TripBookingTextParser.proposal(text: text, sourceName: document.filename)
    }

    func recognize(_ image: CGImage) async throws -> String {
        var request = RecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.automaticallyDetectsLanguage = true
        let observations = try await request.perform(on: image)
        try Task.checkCancellation()
        return observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
    }
}

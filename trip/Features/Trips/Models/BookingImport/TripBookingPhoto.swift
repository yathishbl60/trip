import CoreTransferable
import TripDomain
import UniformTypeIdentifiers

/// Photos provides a temporary file so a full-resolution image never needs an unbounded Data load.
nonisolated struct TripBookingPhoto: Transferable {
    let document: TripBookingDocument

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .image) { received in
            let document = try await TripBookingFileLoader().read(received.file, contentType: .image)
            return Self(document: document)
        }
    }
}

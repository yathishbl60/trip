import Foundation
import TripDomain
import UniformTypeIdentifiers

/// Read a fixed byte budget even if the file grows after its metadata was inspected.
actor TripBookingFileLoader {
    func read(_ url: URL, contentType: UTType? = nil) throws -> TripBookingDocument {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        try Task.checkCancellation()
        let values = try url.resourceValues(forKeys: [.fileSizeKey, .contentTypeKey, .isRegularFileKey])
        guard values.isRegularFile == true else { throw TripBookingImportError.unsupported }
        if let size = values.fileSize, size > TripBookingLimits.maximumFileBytes {
            throw TripBookingImportError.fileTooLarge
        }
        let type = contentType ?? values.contentType ?? UTType(filenameExtension: url.pathExtension)
        let format = try format(for: type)
        let file = try FileHandle(forReadingFrom: url)
        defer { try? file.close() }
        let data = try file.read(upToCount: TripBookingLimits.maximumFileBytes + 1) ?? Data()
        guard data.count <= TripBookingLimits.maximumFileBytes else { throw TripBookingImportError.fileTooLarge }
        try Task.checkCancellation()
        return TripBookingDocument(data: data, filename: url.lastPathComponent, format: format)
    }

    private func format(for type: UTType?) throws -> TripBookingDocument.Format {
        if type?.conforms(to: .pdf) == true { return .pdf }
        if type?.conforms(to: .image) == true { return .image }
        if type?.conforms(to: .plainText) == true { return .text }
        throw TripBookingImportError.unsupported
    }
}

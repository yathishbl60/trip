import Foundation
import PDFKit
import CoreGraphics
import TripDomain

extension TripBookingReader {
    func pdfText(_ data: Data) async throws -> String {
        guard let document = PDFDocument(data: data) else { throw TripBookingImportError.unreadable }
        guard !document.isLocked else { throw TripBookingImportError.lockedPDF }
        guard document.pageCount <= TripBookingLimits.maximumPages else { throw TripBookingImportError.documentTooLong }
        var pages: [String] = []
        for index in 0..<document.pageCount {
            try Task.checkCancellation()
            guard let page = document.page(at: index) else { throw TripBookingImportError.unreadable }
            let embeddedText = page.string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let text = embeddedText.isEmpty ? try await recognize(render(page)) : embeddedText
            pages.append(text)
            guard pages.reduce(0, { $0 + $1.count }) <= TripBookingLimits.maximumTextCharacters else {
                throw TripBookingImportError.documentTooLong
            }
        }
        return pages.joined(separator: "\n\n")
    }

    private func render(_ page: PDFPage) throws -> CGImage {
        guard let page = page.pageRef else { throw TripBookingImportError.unreadable }
        let bounds = page.getBoxRect(.cropBox)
        let scale = CGFloat(TripBookingLimits.maximumImageDimension) / max(bounds.width, bounds.height)
        guard scale.isFinite, scale > 0 else { throw TripBookingImportError.unreadable }
        let target = CGRect(x: 0, y: 0, width: max(1, bounds.width * scale), height: max(1, bounds.height * scale))
        guard let context = CGContext(data: nil, width: Int(target.width), height: Int(target.height), bitsPerComponent: 8,
                                      bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            throw TripBookingImportError.unreadable
        }
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(target)
        context.concatenate(page.getDrawingTransform(.cropBox, rect: target, rotate: 0, preserveAspectRatio: true))
        context.drawPDFPage(page)
        guard let image = context.makeImage() else { throw TripBookingImportError.unreadable }
        return image
    }
}

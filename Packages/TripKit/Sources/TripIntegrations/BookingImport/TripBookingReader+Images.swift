import Foundation
import CoreGraphics
import ImageIO
import TripDomain

extension TripBookingReader {
    func image(from data: Data) throws -> CGImage {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { throw TripBookingImportError.unreadable }
        let options: [CFString: Any] = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                      kCGImageSourceCreateThumbnailWithTransform: true,
                                      kCGImageSourceThumbnailMaxPixelSize: TripBookingLimits.maximumImageDimension]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            throw TripBookingImportError.unreadable
        }
        return image
    }
}

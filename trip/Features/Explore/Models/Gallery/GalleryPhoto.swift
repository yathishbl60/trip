import Foundation
import TripLocalization

/// Retained sample metadata for gallery previews; the images are no longer bundled.
nonisolated struct GalleryPhoto: Identifiable, Sendable {
    let id: String
    let title: TripText
    let aspectRatio: Double

    var imageName: String { "Gallery-\(id)" }
    var thumbnailName: String { "\(imageName)-thumb" }

    static let samples: [GalleryPhoto] = [
        GalleryPhoto(id: "mountain", title: .galleryMountain, aspectRatio: 1600 / 1067),
        GalleryPhoto(id: "lake", title: .galleryLake, aspectRatio: 1600 / 1067),
        GalleryPhoto(id: "forest", title: .galleryForest, aspectRatio: 1600 / 1067),
        GalleryPhoto(id: "coast", title: .galleryCoast, aspectRatio: 1600 / 1067),
        GalleryPhoto(id: "desert", title: .galleryDesert, aspectRatio: 1600 / 1060),
        GalleryPhoto(id: "waterfall", title: .galleryWaterfall, aspectRatio: 1600 / 1067),
        GalleryPhoto(id: "city", title: .galleryCity, aspectRatio: 1600 / 2001),
        GalleryPhoto(id: "canal", title: .galleryCanal, aspectRatio: 1600 / 1067),
        GalleryPhoto(id: "cafe", title: .galleryCafe, aspectRatio: 1600 / 1057),
        GalleryPhoto(id: "hotel", title: .galleryHotel, aspectRatio: 1600 / 1067),
        GalleryPhoto(id: "beach", title: .galleryBeach, aspectRatio: 1600 / 1064),
        GalleryPhoto(id: "terrace", title: .galleryTerrace, aspectRatio: 1600 / 2409)
    ]
}

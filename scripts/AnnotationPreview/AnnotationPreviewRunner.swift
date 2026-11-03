import SwiftUI
import Foundation
import ImageIO
import UniformTypeIdentifiers

@main @MainActor enum AnnotationPreviewRunner {
    static func main() throws {
        let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        try render(.light, to: directory.appendingPathComponent("annotations-light.png"))
        try render(.dark, to: directory.appendingPathComponent("annotations-dark.png"))
    }

    private static func render(_ scheme: ColorScheme, to url: URL) throws {
        let renderer = ImageRenderer(content: AnnotationGalleryView().environment(\.colorScheme, scheme))
        renderer.scale = 2
        guard let image = renderer.cgImage else { throw PreviewError.rendering }
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)
        else { throw PreviewError.encoding }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw PreviewError.encoding }
        print(url.path)
    }
}

enum PreviewError: Error { case rendering, encoding }

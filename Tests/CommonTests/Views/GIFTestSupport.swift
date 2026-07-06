//
//  GIFTestSupport.swift
//

import ImageIO
import UIKit
import UniformTypeIdentifiers

enum TestGIF {

    /// Per-frame delay written into fixtures by default. Three clock tests'
    /// tick margins are chosen relative to this — change them together.
    /// (Distinct from GIFImageView's 0.1s normalization FALLBACK, which
    /// coincidentally has the same value.)
    static let defaultFrameDelay: TimeInterval = 0.1

    /// Builds a small in-memory animated GIF with `frameCount` solid-color frames.
    static func animated(frameCount: Int, delay: TimeInterval = defaultFrameDelay, size: CGSize = .init(width: 4, height: 4)) -> Data {
        let data = NSMutableData()
        let dest = CGImageDestinationCreateWithData(data, UTType.gif.identifier as CFString, frameCount, nil)!
        let fileProps = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] as CFDictionary
        CGImageDestinationSetProperties(dest, fileProps)
        let frameProps = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: delay]] as CFDictionary
        for i in 0..<frameCount {
            let image = solidImage(size: size, hue: CGFloat(i) / CGFloat(max(frameCount, 1)))
            CGImageDestinationAddImage(dest, image, frameProps)
        }
        CGImageDestinationFinalize(dest)
        return data as Data
    }

    /// Writes a GIF into a temporary directory and returns a `Bundle` rooted there,
    /// so `loadGIF(named:in:)` can resolve it. The directory is fixed and reused
    /// (contents overwritten), so repeated runs don't accumulate tmp garbage.
    static func makeBundleContainingGIF(named name: String) throws -> Bundle {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("GIFImageViewTests-fixtures", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try animated(frameCount: 2).write(to: dir.appendingPathComponent("\(name).gif"))
        guard let bundle = Bundle(path: dir.path) else {
            throw NSError(domain: "TestGIF", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not create bundle at \(dir.path)"])
        }
        return bundle
    }

    private static func solidImage(size: CGSize, hue: CGFloat) -> CGImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1).setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image.cgImage!
    }
}
